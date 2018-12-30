%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
%FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Nil Goyette
% University of Sherbrooke
% Sherbrooke, Quebec, Canada. April 2012

function answer = filesys(command, path)
    switch command
        case 'getFiles'
            answer = getFiles(path);
        case 'getFolders'
            answer = getFolders(path);
        case 'mkdir'
            if ~exist(path, 'dir'),
                mkdir(path);
            end
        case 'rmdir'
            if exist(path, 'dir'),
                rmdir(path, 's');
            end
        case 'isEmpty?'
            answer = size(getFiles(path), 2) == 0;
        case 'isValidVideoFolder?'
            fileList = getFiles(path);
            answer = length(intersect(fileList, {'groundtruth', 'input', 'ROI.bmp', 'temporalROI.txt'})) == 4;
        case 'isRootFolder?'
            folderList = getFolders(path);
            answer = length(intersect(folderList, {'dynamicBackground', 'baseline', 'cameraJitter', 'intermittentObjectMotion', 'shadow', 'thermal', 'badWeather', 'lowFramerate', 'nightVideos', 'PTZ', 'turbulence'})) == 11;
    end
end

function files = getFiles(path)
    dirData = dir(path);
    files = {dirData.name};
    files = files(~(strcmp('.', files)|strcmp('..', files)));
end

function folders = getFolders(path)
    dirData = dir(path);
    folders = {dirData([dirData.isdir]).name};
    folders = folders(~(strcmp('.', folders)|strcmp('..', folders)));
end
