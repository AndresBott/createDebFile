#!/usr/bin/env bash

#muss be all lowecase
package_name="myscripts"
current_patch=1


#if set to true asumes that src is the output directory tree to the debian sistem
# for example a executable tree would look like: ./src/usr/bin/executable
# if set to false the relation between files and final location has to be deffined in file: outFileLocations
use_src_as_dir_tree=false

# if you want to place your compiled binaries, or scripts in another folder change this
src_dir="src"

package_dir=out









## clean the stage for generating a deb file
if [ "$1" == "clean" ]
then
  echo "Cleaning stage"
  rm -rf ./build_temp
  exit 1
fi


## check for parameter patch version -p
if [ "$1" == "-p" ]
then
  echo "patch version : $2"
  current_patch=$2;
fi






echo "Reading data from meta/control file"

current_version=$(awk -F ":" '/^Version/ {print $2}' ./meta/control)
current_version=${current_version//[[:blank:]]/}



architecture=$(awk -F ":" '/^Architecture/ {print $2}' ./meta/control)
architecture=${architecture//[[:blank:]]/}



echo "Starting build of Version $current_version"


# deleting old Build if it exists
rm -rf ./build_temp


# creating the folder again
mkdir ./build_temp

# create the data folder to put binaries in
mkdir ./build_temp/data



if [ "$use_src_as_dir_tree" == "true" ];
    then
        echo "Copying source files";
        # use src dir as absolute path locations
        cp -R ./$src_dir/* ./build_temp/data
    else
        # only use files defined in outFileLocatons
        echo "reading files to copy Lines from";

        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [[ ${line:0:1} != "#" ]] && [[ $line != "" ]] ;   then

                    line_part=($line)

                    inFile="./$src_dir/${line_part[0]}";
                    outDir="./build_temp/data${line_part[1]}";


                    if [[ ${line_part[2]} == "" ]]; then
                            fileName=$(basename $inFile);
                        else
                            fileName=${line_part[2]};
                    fi

                    outFile="$outDir/$fileName";

                    echo "coying $inFile to $outFile";
                    test -d "$outDir" || mkdir -p "$outDir" && cp $inFile "$outFile"
            fi

        done < "./outFileLocations"


fi

# create data.tar.gz
cd ./build_temp/data
tar czf ../data.tar.gz [a-z]*
cd ../../
rm -R ./build_temp/data



# create the control file
echo "creating Cotrol File";
cd meta
tar czf ../build_temp/control.tar.gz *
cd ..

cd build_temp

echo 2.0 > ./debian-binary

finalName="$package_name"_"$current_version-$current_patch"_"$architecture.deb"

ar r $finalName debian-binary control.tar.gz data.tar.gz


mv $finalName ../$package_dir


cd ..
echo "Cleaning stage"
rm -rf ./build_temp

echo "Done creating Debian package";

exit 1


