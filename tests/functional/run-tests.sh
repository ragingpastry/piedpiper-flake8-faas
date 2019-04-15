#!/bin/bash

errors=0
for project in \
    python_project; do

    echo "Running tests on project $project in $(dirname $0)/$project"
	pushd $(dirname $0)
	if [[ -f "${project}.zip" ]]; then
	  echo "Removing leftover zipfile ${project}.zip"
	  rm -f "${project}.zip"
	fi
    zip -q "${project}".zip $project/*
	results=$(curl -s -F "files=@${project}.zip" http://127.0.0.1:8080/function/piedpiper-flake8-function)
	expected=(
      "./python_project/functional.py:4:1: F401 'os' imported but unused" \
      "./python_project/functional.py:5:1: F401 'urllib' imported but unused" \
      "./python_project/functional.py:6:1: F401 'uuid' imported but unused" \
      "./python_project/functional.py:11:1: E302 expected 2 blank lines, found 1" \
      "./python_project/functional.py:22:30: W291 trailing whitespace" \
      "./python_project/functional.py:24:1: W293 blank line contains whitespace" \
      "./python_project/functional.py:33:1: E302 expected 2 blank lines, found 1" \
      "./python_project/functional.py:40:8: W291 trailing whitespace" \
      "./python_project/functional.py:43:5: E303 too many blank lines (2)" \
      "./python_project/functional.py:45:9: F841 local variable 'header_auth' is assigned to but never used" \
      "./python_project/functional.py:55:80: E501 line too long (112 > 79 characters)" \
      "./python_project/functional.py:68:80: E501 line too long (89 > 79 characters)" \
      "./python_project/functional.py:75:1: W293 blank line contains whitespace" \
      "./python_project/functional.py:83:1: W293 blank line contains whitespace" \
      "./python_project/functional.py:85:5: E303 too many blank lines (3)" \
      "./python_project/functional.py:85:80: E501 line too long (88 > 79 characters)" \
      "./python_project/functional.py:100:19: W292 no newline at end of file" \
      "./python_project/scanner.py:25:56: W292 no newline at end of file" \
      "./python_project/worker.py:1:1: F401 'json' imported but unused" \
      "./python_project/worker.py:5:1: F401 'time' imported but unused" \
      "./python_project/worker.py:7:1: F401 'charon.config' imported but unused" \
      "./python_project/worker.py:9:1: F811 redefinition of unused 'base' from line 8" \
      "./python_project/worker.py:9:1: F401 'charon.notifications.base' imported but unused" \
      "./python_project/worker.py:14:1: F401 'charon.util' imported but unused" \
      "./python_project/cloud.py:17:54: W292 no newline at end of file" \
      "./python_project/config.py:1:1: F401 'anyconfig' imported but unused"
      "./python_project/config.py:3:1: F401 'os' imported but unused" \
      "./python_project/config.py:14:1: E302 expected 2 blank lines, found 1" \
      "./python_project/config.py:22:5: E303 too many blank lines (2)" \
      "./python_project/config.py:52:5: E303 too many blank lines (2)" \
      "./python_project/config.py:27:5: E303 too many blank lines (2)" \
      "./python_project/config.py:32:5: E303 too many blank lines (2)" \
      "./python_project/config.py:37:5: E303 too many blank lines (2)" \
      "./python_project/config.py:51:1: W293 blank line contains whitespace" \
      "./python_project/config.py:81:10: W292 no newline at end of file" \
      "./python_project/util.py:22:1: E302 expected 2 blank lines, found 1" \
      "./python_project/util.py:37:80: E501 line too long (97 > 79 characters)" \
      "./python_project/util.py:46:80: E501 line too long (117 > 79 characters)" \
      "./python_project/util.py:54:1: W293 blank line contains whitespace" \
      "./python_project/util.py:51:21: E999 SyntaxError: invalid syntax" \
      "./python_project/util.py:57:1: E303 too many blank lines (3)" \
      "./python_project/util.py:85:7: E111 indentation is not a multiple of four" \
      "./python_project/util.py:91:1: E302 expected 2 blank lines, found 1" \
      "./python_project/util.py:115:80: E501 line too long (91 > 79 characters)" \
      "./python_project/util.py:117:80: E501 line too long (115 > 79 characters)" \
      "./python_project/util.py:118:59: E128 continuation line under-indented for visual indent" \
      "./python_project/util.py:118:80: E501 line too long (93 > 79 characters)"
      "./python_project/util.py:119:59: E128 continuation line under-indented for visual indent" \
      "./python_project/util.py:126:69: W291 trailing whitespace" \
      "./python_project/util.py:127:13: E129 visually indented line with same indent as next logical line" \
      "./python_project/util.py:132:9: E303 too many blank lines (2)" \
      "./python_project/util.py:139:80: E501 line too long (99 > 79 characters)" \
      "./python_project/util.py:144:1: W391 blank line at end of file" \
      "./python_project/util.py:144:1: W293 blank line contains whitespace" \
      "./python_project/notification.py:20:61: W292 no newline at end of file"
	)
    while read -r line ; do
	  found=false
	  for i in "${!expected[@]}"; do
	    if [[ "${line}" == "${expected[i]}" ]]; then
		  unset 'expected[i]'
		  found=true
		fi
	  done
	  if [[ ! "${found}" ]]; then
	    echo "Match not found for line ${line}"
		errors=$((errors+1))
	  fi
    done <<< "${results}"
	if [[ "${#expected[@]}" -ne 0 ]]; then
	  echo "Not all expected results found. ${#expected[@]} leftover"
	  echo "Not found: ${expected[@]}"
	  errors=$((errors+1))
	fi
	popd
done

if [[ "${errors}" == 0 ]]; then
    echo "Tests ran successfully";
    exit 0;
else
    echo "Tests failed";
	exit 1;
fi
