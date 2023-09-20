function rap = reproa_vol2surf(rap,command,varargin)

switch command
    case 'doit'

        % Set subject paths
        localPath = getPathByDomain(rap,'subject',varargin{1});
        subjname = spm_file(localPath,'basename');
        setenv('SUBJECTS_DIR', fileparts(localPath))

        % Parse output
        switch getSetting(rap,'outputtype')
            case 'nifti'
                extOut = '.nii';
            case {'gifti' 'cifti'} % CIfTI is also created as a GIfTI first
                extOut = '.gii';
        end

        strInput = rap.tasklist.currenttask.inputstreams(end).name; if iscell(strInput), strInput = strInput{end}; end
        fnInput = getFileByStream(rap,rap.tasklist.currenttask.domain,[varargin{:}],strInput);

        fnOut = {};
        for fn = reshape(fnInput,1,[])
            % check data type
            V = spm_vol(spm_file(fn{1},'number',1));
            if ~lookFor(spm_type(V.dt),'int') % int type required -> convert
                Y = spm_read_vols(spm_vol(fn{1}));
                V.dt = [spm_type('int16') 0];
                delete(fn{1});
                niftiWrite(V,Y);
            end

            % project to surface
            runFreesurferCommand(rap,sprintf('mri_vol2surf --src %s --out %s --regheader %s --hemi lh --projfrac-avg 0.2 0.8 0.1 --interp trilinear',...
                                             fn{1},spm_file(fn{1},'suffix','_lh','ext',extOut),subjname));
            runFreesurferCommand(rap,sprintf('mri_vol2surf --src %s --out %s --regheader %s --hemi rh --projfrac-avg 0.2 0.8 0.1 --interp trilinear',...
                                             fn{1},spm_file(fn{1},'suffix','_rh','ext',extOut),subjname));

            % CIfTI?
            if strcmp(getSetting(rap,'outputtype'),'cifti')
                % Load toolbox
                global reproacache
                NIWF = reproacache('toolbox.niwf');

                % Load header
                fnHeader = char(getFileByStream(rap,rap.tasklist.currenttask.domain,[varargin{:}],[strInput '_header']));
                load(fnHeader,'header');

                % Run conversion
                NIWF.generateCifti(rap,...
                                   fn{1},...
                                   {spm_file(fn{1},'suffix','_lh','ext',extOut) spm_file(fn{1},'suffix','_rh','ext',extOut)},...
                                   header{1}.volumeTR);
                % Update header
                fnHeaderCifti = spm_select('FPList',getPathByDomain(rap,rap.tasklist.currenttask.domain,[varargin{:}]),[spm_file(fn{1},'basename') '.*\.json']);
                hdrCifti = jsonread(fnHeaderCifti);
                header{1} = structUpdate(header{1},hdrCifti);
                if isOctave
                    save('-mat-binary',fnHeader,'header');
                else
                    save(hdrfn,'header');
                end
                putFileByStream(rap,rap.tasklist.currenttask.domain,[varargin{:}],[strInput '_header'],fnHeader);

                fnOut = vertcat(fnOut(:),spm_file(fnHeaderCifti,'ext','.nii'));

                % Cleanup
                delete(spm_file(fn{1},'suffix','_lh','ext',extOut));
                delete(spm_file(fn{1},'suffix','_rh','ext',extOut));
                delete(fnHeaderCifti);
            else
                fnOut = vertcat(fnOut(:),spm_file(fn,'suffix','_lh','ext',extOut),spm_file(fn,'suffix','_rh','ext',extOut));
            end
        end
        putFileByStream(rap,rap.tasklist.currenttask.domain,[varargin{:}],strInput,fnOut);

    case 'checkrequirements'
        % Test FreeSurfer
        runFreesurferCommand(rap,'which freeview');

        % Remove output header if not CIfTI
        if ~strcmp(getSetting(rap,'outputtype'),'cifti')
            strInput = rap.tasklist.currenttask.inputstreams(end).name; if iscell(strInput), strInput = strInput{end}; end
            if find(arrayfun(@(s) any(strcmp(s.name,[strInput '_header'])), rap.tasklist.currenttask.outputstreams),1)
                rap = renameStream(rap,rap.tasklist.currenttask.name,'output',[strInput '_header'],'');
                logging.info('REMOVED: %s output stream: %s', rap.tasklist.currenttask.name,[strInput '_header']);
            end
        end
end
