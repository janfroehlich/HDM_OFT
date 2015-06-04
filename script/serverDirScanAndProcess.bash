#!/bin/bash

source _scriptconf.bash


while ( true ); do
	for dir in $(ls "${UPLOADS_DIRECTORY}"); do
		if [ -d "${UPLOADS_DIRECTORY}/${dir}" ]; then
			if [ ! -d "${PROCESSING_DIRECTORY}/${dir}" ]; then
				echo "------------------------------"
				echo "Process: ${dir}"
				working_dir="${PROCESSING_DIRECTORY}/${dir}"
				zip_file="${UPLOADS_DIRECTORY}/${dir}/${dir}.upload.zip"
				if [ -f "${zip_file}" ]; then
					mkdir "${working_dir}"
					cp "${zip_file}" "${working_dir}/"
					echo $MATLAB_EXE -nodisplay -nosplash -nodesktop -r -sd "${MATLAB_CODE_DIRECTORY}" "HDM_OFT_IDT_CreateBySpectralResponse_In_ZIPorXML('${working_dir}/${dir}.upload.zip','${UPLOADS_DIRECTORY}/${dir}','${dir}'); exit;" -logfile "${working_dir}/IDT_Log.txt" 
				fi
			fi
		fi
	done

	sleep 10
done