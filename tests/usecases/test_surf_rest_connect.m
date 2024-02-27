function test_surf_rest_connect(rap)
% This test script requires the previous execution of the 'fsl' extension test script test_fmrirest.m with the corresponding task list FSL_rest.xml

    rap.acqdetails.input.remoteworkflow(1) = struct(...
       'host','',...
       'path',fullfile(rap.acqdetails.root,'test_fmrirest'),...
       'allowcache',0,...
       'maxtask',''...
       );
    rap = reproaConnect(rap,'subjects','*','runs','*');

    rap = renameStream(rap,'reproa_segment_00001','input',...
                       'structural','reproa_coregextended_00001.structural');
    rap = renameStream(rap,'reproa_segment_00001','input',...
                       't2','reproa_coregextended_t2_00001.t2');

    rap.tasksettings.reproa_segment.writecombined = [0.05 0.05 0.05 0.05 0.5 0]; % remove MP2MPRAGE noise
    rap.tasksettings.reproa_segment.writenormalised.method = 'none';

    rap = renameStream(rap,'reproa_vol2surf_fmri_00001','input',...
                       'fmri','fmri.partial~files');
    rap.tasksettings.reproa_vol2surf_fmri.outputtype = 'cifti';

    processWorkflow(rap);

    reportWorkflow(rap);
end
