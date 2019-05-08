% strip_space : strip leading/tailing spaces from string
%
% CALL :
%   txt=strip_space(txt,type);
%
%   txt[string]
%   type[integer] : [0] strip leading and trailing space (default);
%   type[integer] : [1] strip leading space;
%   type[integer] : [2] strip trailing space;
%
%
% EX :
%  a='    Hei Ho Here We Go      ';
% ['''',strip_space(a),'''']
% ans =
% 'Hello World'
%
%% strip leading space
% ['''',strip_space(a,1),'''']
%% strip trailing space
% ['''',strip_space(a,2),'''']
%

% TMH / 2004
%
function txt=strip_space(txt,type);
if nargin==1
    type=0;
end

if type==0
    txt=strtrim(txt); % OCTAVE COMPLIANT
    return
end

% leading space
if (type==1)
    ispace=strfind(txt,' ');
    if ~isempty(ispace)
        
        if (ispace(1)==1);
            % We have leading blanks
            if length(ispace)==1
                ilast=1;
            else
                ilast=find(diff(ispace)>1);
                if ~isempty(ilast);
                    ilast=ilast(1)-1;
                end
            end
            igood=setxor(1:ilast,1:1:length(txt));
            txt=txt(igood);
        end
    end
    txt=regexprep(txt,'\< ',''); % NOT OCTAVE COMPLIANT
end
% trailing space
if (type==2)
    txt=deblank(txt);
end