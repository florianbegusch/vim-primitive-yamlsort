" BSD 2-Clause License

" Copyright (c) 2021, Florian Begusch
" All rights reserved.

" Redistribution and use in source and binary forms, with or without # modification, are permitted provided that the following conditions are met:

" * Redistributions of source code must retain the above copyright notice, this
  " list of conditions and the following disclaimer.

" * Redistributions in binary form must reproduce the above copyright notice,
  " this list of conditions and the following disclaimer in the documentation
  " and/or other materials provided with the distribution.

" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function PrimitiveYamlSort()
  py3 << EOF

# select line before and after to have regex
# pattern match first and last element properly
start = vim.current.buffer.mark('<')[0] - 1
if start < 0: start = 0
end = vim.current.buffer.mark('>')[0] + 1

buffer_range = vim.current.buffer[start:end]
line_count_initial = len(buffer_range)

content = '\n'.join(buffer_range)

# ---------------------
# regex hokuspokus
import re


number_of_spaces_first_indent = len(vim.current.buffer[start].split('-', 1)[0])
yml_array_elem_regex = \
        re.compile("(?=^" + " " * number_of_spaces_first_indent +  "-)", (re.S|re.M))

yaml_array = yml_array_elem_regex.split(content)
yaml_array[len(yaml_array)-1], line_after_select = \
  yaml_array[len(yaml_array)-1].rsplit('\n', 1)

for index, element in enumerate(yaml_array):
    yaml_array[index] = element.replace('\n', '')

line_count_after_hokuspokus = len(yaml_array)

# ---------------------


# replace buffer content with hokuspokus
vim.current.buffer[start:end] = yaml_array


# sort hokuspokused selection
sort_command = f'{start+1},{end-line_count_after_hokuspokus+1}sort'
vim.command(sort_command)


# refresh content
buffer_range = vim.current.buffer[start:end-line_count_after_hokuspokus+1]
content = '\n'.join(buffer_range)
yaml_array = content.splitlines()
if not yaml_array[0]:
  del yaml_array[0]


# --------------------------
# undo regex hokuspokus


yml_sub_elem_regex = \
        re.compile("(?=\s{" + str(2 + number_of_spaces_first_indent) + ",})", (re.S|re.M))

yaml_array_new = []
for index, element in enumerate(yaml_array):

    sub_array = yml_sub_elem_regex.split(element)
    if len(sub_array) > 1:
        for subelement in sub_array:
            yaml_array_new.append(subelement)
    else:
        yaml_array_new.append(element)

# TODO maybe clean this up
#
# This inserts the line after the selection
# which had to be added to the selection in
# order for the regex pattern to match.
#
yaml_array_new.append(line_after_select)

# replace buffer, undo hokuspokus
vim.current.buffer[start:end-line_count_after_hokuspokus+1] = yaml_array_new

# --------------------------

EOF
endfunction

" TODO list:
" * key map
" * set custom initial yaml indentation
"   (now set to 2, and subelements start at 4)

