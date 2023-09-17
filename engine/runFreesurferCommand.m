function [s, w] = runFreesurferCommand(rap,cmd,ENV,varargin)
% Setup
setupCmd = '';
setupStr = deblank(rap.directoryconventions.freesurfersetup);
if not(isempty(setupStr))
    if ~startsWith(setupStr,'. '), setupStr = ['. ' setupStr]; end
    if ~endsWith(setupStr,';'), setupStr=[setupStr ';']; end
    setupCmd = [setupCmd setupStr];
end

% - environment setup must go just before cmd
setupStr = deblank(rap.directoryconventions.freesurferenvironment);
if not(isempty(setupStr))
    if ~startsWith(setupStr,'. '), setupStr = ['. ' setupStr]; end
    if ~endsWith(setupStr,';'), setupStr=[setupStr ';']; end
    cmd = [setupStr cmd];
end

% Parse (e.g., when called from runPyCommand)
indShPfx  = find(strcmp(varargin,'shellprefix'));
if ~isempty(indShPfx)
    setupCmd = [varargin{indShPfx+1} setupCmd];
    varargin(indShPfx:indShPfx+1) = [];
end

if nargin < 3, ENV = {}; end
if nargin < 5, varargin = {}; end

global reproacache
if ~reproacache.isKey('toolbox.spm'), logging.error('SPM is not found'); end
SPMtool = reproacache('toolbox.spm');
ENV = vertcat(ENV,{...
    'SUBJECTS_DIR',getenv('SUBJECTS_DIR');...
    'FREESURFER_HOME',rap.directoryconventions.freesurferdir;...
    'FSF_OUTPUT_FORMAT',rap.directoryconventions.freesurferoutputformat;...
    'MATLABPATH', SPMtool.toolPath;...
    });

[s, w] = shell(cmd,'shellprefix',setupCmd,'environment',ENV,varargin{:});
end
