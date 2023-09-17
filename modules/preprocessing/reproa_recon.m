function rap = reproa_recon(rap,command,subj)

FSDERIV = {'label' 'mri' 'scripts' 'stats' 'surf' 'touch'}; % ? tmp

switch command
    case 'doit'

        % Set subject paths
        localPath = getPathByDomain(rap,'subject',subj);
        subjname = spm_file(localPath,'basename');

        setenv('SUBJECTS_DIR', fileparts(localPath))

        % Clean for all
        if strcmp(getSetting(rap,'workflow'),'all')
            cellfun(@(d) dirRemove(fullfile(localPath,d)), FSDERIV)
        end

        % Delete freesurfer running flags if exists
        if exist(fullfile(localPath,'scripts','IsRunning.lh+rh'), 'file')
            delete(fullfile(localPath,'scripts','IsRunning.lh+rh'));
        end

        % Initialise with obligatory input (T1)
        dirMake(fullfile(localPath,'mri','orig'));
        imgT1 = getFileByStream(rap,'subject',subj,'structural');
        for i = 1:numel(imgT1)
            [s, w] = runFreesurferCommand(rap,sprintf('mri_convert %s %s',...
                                                      imgT1{i},...
                                                      fullfile(localPath,'mri','orig',sprintf('%03d.mgz',i))));
        end

        % Additional input (T2 -> FLAIR, only one is selected!)
        for inStream = {'t2' 'flair'}
            if hasStream(rap,'subject',subj,inStream{1})
                inputStr = ['-' upper(inStream{1}) ' '...
                            char(getFileByStream(rap,'subject',subj,inStream{1}))...
                            ' -' upper(inStream{1}) 'pial'];
                break;
            end
        end

        % Run
        fsCmd = ['recon-all -subjid ' subjname ' ' inputStr ' -'  getSetting(rap,'workflow')];
        [s, w] = runFreesurferCommand(rap,fsCmd);

        % Output
        % - specific FreesSrfer dirs into specific substream
        for outDir = FSDERIV
            output.(outDir{1}) = cellstr(spm_select('FPListRec',fullfile(localPath,outDir{1}),'.*'));
        end
        putFileByStream(rap,'subject',subj,'recon',output);

    case 'checkrequirements'
        % Test FreeSurfer
        runFreesurferCommand(rap,'which freeview');
end
