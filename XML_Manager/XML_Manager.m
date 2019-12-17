% /**
%  * Author:    Andrea Casalino
%  * Created:   17.12.2019
% *
% * report any bug to andrecasa91@gmail.com.
%  **/

function XML=XML_Manager(name_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% name_file is the name of the file to read. %
% Absolute and relative paths are accepted  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose('all');

File=fopen(name_file);
fgetl(File);
line=1;

slices=my_split(fgetl(File)); line=line+1;
if(nargin > 1)
    root_tag = read_Tag(File, slices, line, name_path);
else
    root_tag = read_Tag(File, slices, line);
end
XML.(root_tag.name) = root_tag.content;

if( ~feof(File)  )
    error('multiple root Tag found');
end

fclose(File);
 
end

function [Tag,line]=read_Tag(File, slices, line)

line_open=line;
if(slices{1}(1)  ~= '<' )
    error( [ 'line ',  num2str(line), ' expected a <' ] );
end

terminator_found=0;
if( length(slices) == 1 )
    if(slices{1}(end) ~= '>' )
        error( [ 'line ',  num2str(line), ' expected a >' ] );
    end
    Tag.name=slices{1}(2:(end-1));
    slices{1}='>';
else
    Tag.name=slices{1}(2:end);
    Tag.name = slices{1}(2:end);
    slices=pop_front(slices);
    temp_L=length(Tag.name)+3;
    if( length(slices{end}) >= temp_L )
        temp=extract_back(slices{end}, temp_L);
        if( strcmp(temp,['</',Tag.name,'>']) == 1 )
            terminator_found=1;
            slices{end}=slices{end}( 1:(end-temp_L) );
            if(length(slices{end}) == 0)
                slices=pop_back(slices);
            end
        end
    end
end

if( length(slices) == 0 )
        error( [ 'line ',  num2str(line), ' expected a >' ] );
end
if( slices{end}(end)  ~= '>' )
        error( [ 'line ',  num2str(line), ' expected a >' ] );
end

slices{end}=slices{end}(1:(end-1));
if( length(slices{end}) == 0 )
    slices=pop_back(slices);
end

%%%%%%%%%%%%%%
%  import the fields   %
%%%%%%%%%%%%%%
Tag.content = struct();
for k=1:length(slices)
    field_temp = Extract_word(slices{k}, line);
    
        if(isfield(Tag.content, field_temp.name) == 1)
            if(iscell(Tag.content.(field_temp.name)) == 0)
                Tag.content.(field_temp.name) = {Tag.content.(field_temp.name) ,  field_temp.content};
            else
                Tag.content.(field_temp.name){ length(Tag.content.(field_temp.name)) + 1} = field_temp.content;
            end
        else
            Tag.content.(field_temp.name) = field_temp.content;
        end
end
if(terminator_found==1)
    return;
end

%%%%%%%%%%%%%%%
%  import nested tags   %
%%%%%%%%%%%%%%%
while( ~feof(File) )
    slices=my_split(fgetl(File)); line=line+1;
    
    if(  strcmp( slices{1}, ['</', Tag.name,'>']) == 1 )
        return;
    end
    
    [Tag_nested,line]=read_Tag(File, slices, line);
    
    if(isfield(Tag.content , Tag_nested.name) == 1)
        if(iscell(Tag.content.(Tag_nested.name)) == 0)
            Tag.content.(Tag_nested.name) = {Tag.content.(Tag_nested.name) ,  Tag_nested.content};
        else
            Tag.content.(Tag_nested.name){ length(Tag.content.(Tag_nested.name)) + 1} = Tag_nested.content;
        end
    else
        Tag.content.(Tag_nested.name) = Tag_nested.content;
    end
end

error(['Tag opened at line ',  num2str(line_open), ' not closed']);

end

function Field=Extract_word(word_raw, line)

pos_equal=1;
for k=1:length(word_raw)
    if(word_raw(k) ==  '=' )
        pos_equal=k;
        break;
    end
end
if(pos_equal == 1)
     error( [ 'invalid word line ',  num2str(line) ] );
end

Field.name    = word_raw(1:(pos_equal-1));
Field.content = word_raw((pos_equal+1):end);

if( ( Field.content(1) ~= '"' ) || ( Field.content(end) ~= '"' ) )
     error( [ 'invalid word line ',  num2str(line) ] );
end

Field.content=Field.content(2:(end-1));

end

function slices=my_split(line)

slices=strsplit(strtrim(line));

end

function slices=pop_front(slices)

L=length(slices);
if( L == 1 )
    slices={};
elseif( L == 2 )
    temp{1}=slices{2};
    slices=temp;
else
    for k=2:L
        temp{k-1}=slices{k};
    end
    slices=temp;
end

end

function slices=pop_back(slices)

L=length(slices);
if( L == 1 )
    slices={};
elseif( L == 2 )
    temp{1}=slices{1};
    slices=temp;
else
    for k=1:(L-1)
        temp{k}=slices{k};
    end
    slices=temp;
end

end

function back=extract_back(word, back_size)

back=word((end-back_size+ 1):end);

end
