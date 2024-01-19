#! /bin/bash

# Finding roots
cd $(cd "$(dirname "$0")"; pwd -P)

if [[ -z $@ ]]
then
  echo "What to edit?!"
  exit
fi

while [[ ! -z $@ ]]
do
  if [[ $1 == "--help" ]]
  then
    echo ""
    echo "This script is used to create/delete/edit pages"
    echo ""
    echo "Options:"
    echo "-l                  List files and exit"
    echo "-n                  Create new page"
    echo "-r                  Remove page"
    echo "-u                  Unlink project/article"
    echo "-a                  Specifies archived project page"
    echo "-A                  Specifies article page"
    echo "-d                  Specifies description file"
    echo "-p                  Specifies project page"
    echo "-h                  Specifies head file"
    echo ""
    exit
  fi
  if [[ ${1:0:2} == "-l" ]]
  then
    echo ">> Regular pages <<"
    for i in $(ls -p ./PageContent | grep -v /)
    do
      echo $i
    done
    echo ""
    echo ">> Project pages <<"
    for i in $(ls -p ./PageContent/Projects | grep -v /)
    do
      if [[ ${i:0:2} != "A-" ]]
      then
        echo $i
      else
        if [[ -e ./PageContent/Archived/$i ]]
        then
          echo "${i:2:250} (Halted)"
        fi
      fi
    done
    echo ""
    echo ">> Archived pages <<"
    for i in $(ls -p ./PageContent/Archived | grep -v /)
    do
      if [[ ${i:0:2} != "A-" ]]
      then
        echo $i
      fi
    done
    echo ""
    echo ">> Article pages <<"
    for i in $(ls -p ./PageContent/Resources | grep -v /)
    do
      if [[ ${i:0:2} != "A-" ]]
      then
        echo $i
      else
        echo "${i:2:250} (Archived)"
      fi
    done
    echo ""
    exit
  fi
  if [[ ${1:0:1} == "-" ]]
  then
    i=1
    while [[ ! -z ${1:i:1} ]]
    do
      case ${1:i:1} in
            a ) Archived=true
                ;;
            A ) Article=true
                ;;
            d ) Description=true
                ;;
            p ) Project=true
                ;;
            n ) NewFile=true
                ;;
            h ) Head=true
                ;;
            u ) Unlink=true
                ;;
            r ) Remove=true
                ;;
             *) echo "Fatal: Unknown option!"
                exit
                ;;
      esac
      i=$(( $i + 1 ))
    done
    shift
  else
    FileName=$1
    shift
  fi
done

# Edit menu
if [[ $FileName == Menu ]]
then
  echo 'Opening menu, any specified option will be ignored!'
  gedit ./Menu
  exit
fi
# Error checking
if [[ $Archived == true && $Project == true ]]
then
  echo 'Error: Both "a" and "p" options specified!'
  read -p "Project or Archived page? (Project = p / Archived = a / anything else = abort)" Answer
  if [[ $Answer == "a" ]]
  then
    Project=false
  else
      if [[ $Answer == "p" ]]
    then
      Archived=false
    else
      echo "Communication error! (PEBKEC :P)"
      exit
    fi
  fi
fi
if [[ $Archived == true && $Article == true || $Project == true && $Article == true ]]
then
  echo "Error: Can not work on 2 kind of page at once..."
  exit
fi
if [[ $Head == true && $Description == true ]]
then
  echo 'Error: Both "d" and "h" options specified!'
  read -p "Head or Description file? (Head = h / Description = d / page = p / anything else = abort)" Answer
  if [[ $Answer == "h" ]]
  then
    Description=false
  else
      if [[ $Answer == "d" ]]
    then
      Head=false
    else
      if [[ $Answer == "p" ]]
      then
        Head=false
        Description=false
      else
        echo "Communication error! (PEBKEC :P)"
        exit
      fi
    fi
  fi
fi
if [[ $Archived != true && $Project != true && $Article != true && $Description == true ]]
then
  echo "Fatal: Regular pages do not require description files! Only Projects, and Archived projects..."
  exit
fi
if [[ $Unlink == true && $Archived != true && $Project != true && $Article != true ]]
then
  echo 'Fatal: Only projects and archived projects can have description files!'
  exit
fi
if [[ $Remove == true ]]
then
  if [[ $Unlink == true ]]
  then
    echo 'Warning: -u option is not necessary when removing pages. It will be ignored!'
    Unlink=false
  fi
  if [[ $NewFile == true ]]
  then
    echo 'Fatal: Create and remove are conflicting operations!'
    exit
  fi
fi

# Delete and unlink feature
if [[ $Remove == true ]]
then
  echo ''
  if [[ $Project == true || $Archived == true ]]
  then
    if [[ -e ./HeadContent/Projects/$FileName.html ]]
    then
      DList="$DList HeadContent/Projects/$FileName.html"
    fi
    if [[ -e ./HeadContent/Archived/$FileName.html ]]
    then
      DList="$DList HeadContent/Archived/$FileName.html"
    fi
    if [[ -e ./PageContent/Projects/$FileName.html ]]
    then
      DList="$DList PageContent/Projects/$FileName.html"
    fi
    if [[ -e ./PageContent/Archived/$FileName.html ]]
    then
      DList="$DList PageContent/Archived/$FileName.html"
    fi
    if [[ -e ./PageContent/Projects/A-$FileName.html ]]
    then
      DList="$DList PageContent/Projects/A-$FileName.html"
    fi
    if [[ -e ./PageContent/Archived/A-$FileName.html ]]
    then
      DList="$DList PageContent/Archived/A-$FileName.html"
    fi
    if [[ -e ./PageContent/Archived/Description/D-$FileName ]]
    then
      DList="$DList PageContent/Archived/Description/D-$FileName"
    fi
    if [[ -e ./PageContent/Projects/Description/D-$FileName ]]
    then
      DList="$DList PageContent/Projects/Description/D-$FileName"
    fi
  else
    if [[ $Article == true ]]
    then
      if [[ -e ./HeadContent/Resources/$FileName.html ]]
      then
        DList="$DList HeadContent/Resources/$FileName.html"
      fi
      if [[ -e ./PageContent/Resources/$FileName.html ]]
      then
        DList="$DList PageContent/Resources/$FileName.html"
      fi
      if [[ -e ./PageContent/Resources/A-$FileName.html ]]
      then
        DList="$DList PageContent/Resources/A-$FileName.html"
      fi
      if [[ -e ./PageContent/Resources/Description/D-$FileName ]]
      then
        DList="$DList PageContent/Resources/Description/D-$FileName"
      fi
    else
      if [[ -e ./HeadContent/$FileName.html ]]
      then
        DList="$DList HeadContent/$FileName.html"
      fi
      if [[ -e ./PageContent/$FileName.html ]]
      then
        DList="$DList PageContent/$FileName.html"
      fi
    fi
  fi
  if [[ ! -z $DList ]]
  then
  if [[ ! -z $(echo $DList | grep Projects/A-$FileName.html) && ! -z $(echo $DList | grep Archived/A-$FileName.html) ]]
  then
    echo "Fatal: Halted project can not be deleted! Please resume the project and try again!"
    exit
  fi
  echo 'The following files are marked for removal:'
  for i in $DList
  do
    echo $i
  done
  echo ''
  # Check references
  if [[ ! -z $(cat ./Menu | grep $FileName) ]]
  then
    echo "Warning: Main menu contains reference to $FileName.html. Please remove the link(s)! Deleting this project will break the link, leading to 404 error!"
  fi
  for i in $DList
  do
    if [[ ! -z $(echo $i | grep PageContent) && -z $(echo $i | grep Description) && -z $(echo $i | grep A-$FileName.html) ]] # waste of time to search in header and description files...
    then
      for n in $(ls ./PageContent)
      do
        if [[ -f ./PageContent/$n && -z $(echo $i | grep $n) ]] # avoid searching in itself
        then
          if [[ ! -z $(cat ./PageContent/$n | grep $FileName.html) && -z $(echo $n | grep Projects.html) && -z $(echo $n | grep Resources.html) ]]
          then
            echo "Warning: Page $n contains reference to $FileName.html. Please remove the link(s)! Deleting this project will break the link, leading to 404 error!"
            echo ''
          fi
          if [[ ! -z $(cat $i | grep $n) ]]
          then
            echo "Warning: The page marked for deletion $i contains reference to page $n! Page $n may also be deleted if nothing else refers to it."
            echo ''
          fi
        fi
      done
      for n in $(ls ./PageContent/Archived)
      do
        if [[ -f ./PageContent/Archived/$n && -z $(echo $i | grep $n) && $n != A-$FileName.html ]] # avoid searching in itself and placeholder(this is why it can't search in halted project...)
        then
          if [[ ! -z $(cat ./PageContent/Archived/$n | grep $FileName.html) ]]
          then
            echo "Warning: Archived project $n contains reference to $FileName.html. Please remove the link(s)! Deleting this project will break the link, leading to 404 error!"
            echo ''
          fi
          if [[ ! -z $(cat $i | grep $n) ]]
          then
            echo "Warning: The page marked for deletion $i contains reference to archived project page $n! Page $n may also be deleted if nothing else refers to it."
            echo ''
          fi
        fi
      done
      for n in $(ls ./PageContent/Projects)
      do
        if [[ -f ./PageContent/Projects/$n && -z $(echo $i | grep $n) && $n != A-$FileName.html ]] # avoid searching in itself and placeholder(this is why it can't search in halted project...)
        then
          if [[ ! -z $(cat ./PageContent/Projects/$n | grep $FileName.html) ]]
          then
            echo "Warning: Active project $n contains reference to $FileName.html. Please remove the link(s)! Deleting this project will break the link, leading to 404 error!"
            echo ''
          fi
          if [[ ! -z $(cat $i | grep $n) ]]
          then
            echo "Warning: The page marked for deletion $i contains reference to active project page $n! Page $n may also be deleted if nothing else refers to it."
            echo ''
          fi
        fi
      done
      for n in $(ls ./PageContent/Resources)
      do
        if [[ -f ./PageContent/Resources/$n && -z $(echo $i | grep $n) ]] # avoid searching in itself but this has no placeholder... it's just renamed to avoid re-generating each time
        then
          if [[ ! -z $(cat ./PageContent/Resources/$n | grep $FileName.html) ]]
          then
            echo "Warning: Article $n contains reference to $FileName.html. Please remove the link(s)! Deleting this article will break the link, leading to 404 error!"
            echo ''
          fi
          if [[ ! -z $(cat $i | grep $n) ]]
          then
            echo "Warning: The page marked for deletion $i contains reference to article page $n! Page $n may also be deleted if nothing else refers to it."
            echo ''
          fi
        fi
      done
    fi
  done
    echo ''
    read -p "Delete operation is not reversible! Are you sure about this? (y/n): " Yy
    if [[ $Yy == [yY]* ]]
    then
      for i in $DList
      do
        rm ./$i
      done
    fi
    exit
  else
    echo 'No files to remove!'
    exit
  fi
fi
if [[ $Unlink == true ]]
then
  if [[ $Archived == true && -e ./PageContent/Archived/Description/D-$FileName ]]
  then
    DList="$DList PageContent/Archived/Description/D-$FileName"
  fi
  if [[ $Project == true && -e ./PageContent/Projects/Description/D-$FileName ]]
  then
    DList="$DList PageContent/Projects/Description/D-$FileName"
  fi
  if [[ $Article == true && -e ./PageContent/Resources/Description/D-$FileName ]]
  then
    DList="$DList PageContent/Resources/Description/D-$FileName"
  fi
  if [[ ! -z $DList ]]
  then
    echo 'The following files are marked for removal:'
    for i in $DList
    do
      echo $i
    done
    echo ''
    read -p "Deleting the description file is not reversible! Are you sure about this? (y/n): " Yy
    if [[ $Yy == [yY]* ]]
    then
      for i in $DList
      do
        rm ./$i
      done
    fi
    exit
  else
    echo 'The specified project is not linked!'
    exit
  fi
fi

# Checking if page already exists and creating page
if [[ $NewFile == true ]]
then
  if [[ $Project == true || $Archived == true ]]
  then
    if [[ -f ./PageContent/$FileName.html || -f ./PageContent/Projects/$FileName.html || -f ./PageContent/Archived/$FileName.html || -f ./PageContent/Projects/A-$FileName.html || -f ./PageContent/Resources/$FileName.html || -f ./PageContent/Resources/A-$FileName.html ]]
    then
      echo 'Fatal: Specified file name already exists! Please pick something else...'
      exit
    else
      if [[ $Archived == true ]]
      then
        echo 'Creating Archived page'
        touch ./PageContent/Archived/$FileName.html
        echo '    <!-- Remember! In order to insert an image or link to downloadable file, from Files or Images folder, the path must start with ../ in front instead of ./ since this file is in a subdirectory already. -->' >> ./PageContent/Archived/$FileName.html
        echo '    <!-- Leave the markers untouched! -->' >> ./PageContent/Archived/$FileName.html
        echo -n '<!--TitleMarker--><h1 style="text-align: center">' >> ./PageContent/Archived/$FileName.html
        echo "Project: $FileName" >> ./PageContent/Archived/$FileName.html
        echo '</h1>' >> ./PageContent/Archived/$FileName.html
        echo '' >> ./PageContent/Archived/$FileName.html
        echo '<div style="width 100%; float: left">' >> ./PageContent/Archived/$FileName.html
        InfoList="Author: License: Category: Status: Version:"
        for i in $InfoList
        do
          echo '  <span style="min-width: 420px; float: left">' >> ./PageContent/Archived/$FileName.html
          echo '    <table style="float: left">' >> ./PageContent/Archived/$FileName.html
          echo '      <tr>' >> ./PageContent/Archived/$FileName.html
          echo -n '        <td>' >> ./PageContent/Archived/$FileName.html
          if [[ $i == "Version:" ]]
          then
            echo -n "Latest $i" >> ./PageContent/Archived/$FileName.html
          else
            echo -n "$i" >> ./PageContent/Archived/$FileName.html
          fi
          echo '</td>' >> ./PageContent/Archived/$FileName.html
          echo '        <td style="width: 10px"></td>' >> ./PageContent/Archived/$FileName.html
          if [[ $i == "Category:" ]]
          then
            echo '        <td> Undefined </td> <!--CategoryMarker-->' >> ./PageContent/Archived/$FileName.html
          else
            echo '        <td>Undefined</td>' >> ./PageContent/Archived/$FileName.html
          fi
          echo '      </tr>' >> ./PageContent/Archived/$FileName.html
          echo '    </table>' >> ./PageContent/Archived/$FileName.html
          echo '  </span>' >> ./PageContent/Archived/$FileName.html
        done
        echo '</div>' >> ./PageContent/Archived/$FileName.html
        echo '' >> ./PageContent/Archived/$FileName.html
        echo '<!-- Uncomment and complete this if there are sponsors...' >> ./PageContent/Archived/$FileName.html
        echo '<div style="width: 100%; float: left">' >> ./PageContent/Archived/$FileName.html
        echo '  <h2>Sponsors: </h2>' >> ./PageContent/Archived/$FileName.html
        echo '  <a href=""><img src=""></a>' >> ./PageContent/Archived/$FileName.html
        echo '</div>' >> ./PageContent/Archived/$FileName.html
        echo '-->' >> ./PageContent/Archived/$FileName.html
        echo '' >> ./PageContent/Archived/$FileName.html
        echo '<div class="TranslucentPanel" style="width: 100%; float: left"><div class="PanelArea">' >> ./PageContent/Archived/$FileName.html
        echo '<!--Page content here!-->' >> ./PageContent/Archived/$FileName.html
        echo '<h2>SUBTITLE</h2>' >> ./PageContent/Archived/$FileName.html
        echo '<p>DESCRIPTION</p>' >> ./PageContent/Archived/$FileName.html
        echo '<a href="LINK"><h2>Github repository</h2></a>' >> ./PageContent/Archived/$FileName.html
        echo '</div></div>' >> ./PageContent/Archived/$FileName.html
        echo '' >> ./PageContent/Archived/$FileName.html
        echo '<!--Place everything in divisions like this: <div style="width: 100%; float: left"></div> otherwise it is gonna be a mess...-->' >> ./PageContent/Archived/$FileName.html
        echo '<div style="width: 100%; height: 100px; float: left"><!--This division should be the last thing in the page content!--></div>' >> ./PageContent/Archived/$FileName.html
        touch ./HeadContent/Archived/$FileName.html
        echo '    <!-- Meta data (Title, keywords, and description should be changed for each page...) -->' >> ./HeadContent/Archived/$FileName.html
        echo "    <title>OSRC/$FileName</title>" >> ./HeadContent/Archived/$FileName.html
        echo '    <meta charset="utf-8">' >> ./HeadContent/Archived/$FileName.html
        echo '    <meta name="viewport" content="width=device-width, initial-scale=1">' >> ./HeadContent/Archived/$FileName.html
        echo '    <meta name="Keywords" content="">' >> ./HeadContent/Archived/$FileName.html
        echo '    <meta name="Description" content="">' >> ./HeadContent/Archived/$FileName.html
        echo '    <link rel="icon" href="../Images/Common/Icon.png" type="image/x-icon">' >> ./HeadContent/Archived/$FileName.html
        echo '    <!-- Google font(s) -->' >> ./HeadContent/Archived/$FileName.html
        echo '    <link href="https://fonts.googleapis.com/css?family=Spectral+SC|Vollkorn" rel="stylesheet">' >> ./HeadContent/Archived/$FileName.html
        echo '    <!-- Style -->' >> ./HeadContent/Archived/$FileName.html
        echo '    <!-- Style sheets are managed by the construct.sh scipt, if you need to add another style sheet do it here for this page, of in the construct script for all pages or for Dark/Light pages separately-->' >> ./HeadContent/Archived/$FileName.html
        echo '    <!-- PageStyleDark.css (Leave this comment here for the Construct script to find where to insert style sheets) -->' >> ./HeadContent/Archived/$FileName.html
        echo '    <!-- Animation -->' >> ./HeadContent/Archived/$FileName.html
      else
        echo 'Creating Project page'
        touch ./PageContent/Projects/$FileName.html
        echo '    <!-- Remember! In order to insert an image or link to downloadable file, from Files or Images folder, the path must start with ../ in front instead of ./ since this file is in a subdirectory already. -->' >> ./PageContent/Projects/$FileName.html
        echo '    <!-- Leave the markers untouched! -->' >> ./PageContent/Projects/$FileName.html
        echo -n '<!--TitleMarker--><h1 style="text-align: center">' >> ./PageContent/Projects/$FileName.html
        echo "Project: $FileName" >> ./PageContent/Projects/$FileName.html
        echo '</h1>' >> ./PageContent/Projects/$FileName.html
        echo '' >> ./PageContent/Projects/$FileName.html
        echo '<div style="width 100%; float: left">' >> ./PageContent/Projects/$FileName.html
        InfoList="Author: License: Category: Status: Version:"
        for i in $InfoList
        do
          echo '  <span style="min-width: 420px; float: left">' >> ./PageContent/Projects/$FileName.html
          echo '    <table style="float: left">' >> ./PageContent/Projects/$FileName.html
          echo '      <tr>' >> ./PageContent/Projects/$FileName.html
          echo -n '        <td>' >> ./PageContent/Projects/$FileName.html
          if [[ $i == "Version:" ]]
          then
            echo -n "Latest $i" >> ./PageContent/Projects/$FileName.html
          else
            echo -n "$i" >> ./PageContent/Projects/$FileName.html
          fi
          echo '</td>' >> ./PageContent/Projects/$FileName.html
          echo '        <td style="width: 10px"></td>' >> ./PageContent/Projects/$FileName.html
          if [[ $i == "Category:" ]]
          then
            echo '        <td> Undefined </td> <!--CategoryMarker-->' >> ./PageContent/Projects/$FileName.html
          else
            echo '        <td>Undefined</td>' >> ./PageContent/Projects/$FileName.html
          fi
          echo '      </tr>' >> ./PageContent/Projects/$FileName.html
          echo '    </table>' >> ./PageContent/Projects/$FileName.html
          echo '  </span>' >> ./PageContent/Projects/$FileName.html
        done
        echo '</div>' >> ./PageContent/Projects/$FileName.html
        echo '' >> ./PageContent/Projects/$FileName.html
        echo '<!-- Uncomment and complete this if there are sponsors...' >> ./PageContent/Projects/$FileName.html
        echo '<div style="width: 100%; float: left">' >> ./PageContent/Projects/$FileName.html
        echo '  <h2>Sponsors: </h2>' >> ./PageContent/Projects/$FileName.html
        echo '  <a href=""><img src=""></a>' >> ./PageContent/Projects/$FileName.html
        echo '</div>' >> ./PageContent/Projects/$FileName.html
        echo '-->' >> ./PageContent/Projects/$FileName.html
        echo '' >> ./PageContent/Projects/$FileName.html
        echo '<div class="TranslucentPanel" style="width: 100%; float: left"><div class="PanelArea">' >> ./PageContent/Projects/$FileName.html
        echo '<!--Page content here!-->' >> ./PageContent/Projects/$FileName.html
        echo '<h2>SUBTITLE</h2>' >> ./PageContent/Projects/$FileName.html
        echo '<p>DESCRIPTION</p>' >> ./PageContent/Projects/$FileName.html
        echo '<h2>DownloadLink</h2>' >> ./PageContent/Projects/$FileName.html
        echo '<a href="LINK"><h2>Github repository</h2></a>' >> ./PageContent/Projects/$FileName.html
        echo '<p><b>Please consider <a href="../Support.html">donating</a> to help keep all this freely available! Thank you!</b></p>' >> ./PageContent/Projects/$FileName.html
        echo '</div></div>' >> ./PageContent/Projects/$FileName.html
        echo '' >> ./PageContent/Projects/$FileName.html
        echo '<!--Place everything in divisions like this: <div style="width: 100%; float: left"></div> otherwise it is gonna be a mess...-->' >> ./PageContent/Projects/$FileName.html
        echo '<div style="width: 100%; height: 100px; float: left"><!--This division should be the last thing in the page content!--></div>' >> ./PageContent/Projects/$FileName.html
        touch ./HeadContent/Projects/$FileName.html
        echo '    <!-- Meta data (Title, keywords, and description should be changed for each page...) -->' >> ./HeadContent/Projects/$FileName.html
        echo "    <title>OSRC/$FileName</title>" >> ./HeadContent/Projects/$FileName.html
        echo '    <meta charset="utf-8">' >> ./HeadContent/Projects/$FileName.html
        echo '    <meta name="viewport" content="width=device-width, initial-scale=1">' >> ./HeadContent/Projects/$FileName.html
        echo '    <meta name="Keywords" content="">' >> ./HeadContent/Projects/$FileName.html
        echo '    <meta name="Description" content="">' >> ./HeadContent/Projects/$FileName.html
        echo '    <link rel="icon" href="../Images/Common/Icon.png" type="image/x-icon">' >> ./HeadContent/Projects/$FileName.html
        echo '    <!-- Google font(s) -->' >> ./HeadContent/Projects/$FileName.html
        echo '    <link href="https://fonts.googleapis.com/css?family=Spectral+SC|Vollkorn" rel="stylesheet">' >> ./HeadContent/Projects/$FileName.html
        echo '    <!-- Style -->' >> ./HeadContent/Projects/$FileName.html
        echo '    <!-- Style sheets are managed by the construct.sh scipt, if you need to add another style sheet do it here for this page, of in the construct script for all pages or for Dark/Light pages separately-->' >> ./HeadContent/Projects/$FileName.html
        echo '    <!-- PageStyleDark.css (Leave this comment here for the Construct script to find where to insert style sheets) -->' >> ./HeadContent/Projects/$FileName.html
        echo '    <!-- Animation -->' >> ./HeadContent/Projects/$FileName.html
      fi
    fi
  else
    if [[ -f ./PageContent/$FileName.html || -f ./PageContent/Projects/$FileName.html || -f ./PageContent/Archived/$FileName.html || -f ./PageContent/Projects/A-$FileName.html || -f ./PageContent/Resources/$FileName.html || -f ./PageContent/Resources/A-$FileName.html ]]
    then
      echo 'Fatal: Specified file name already exists! Please pick something else...'
      exit
    else
      if [[ $Article == true ]]
      then
        echo 'Creating Article page'
        touch ./PageContent/Resources/$FileName.html
        echo '    <!-- Remember! In order to insert an image or link to downloadable file, from Files or Images folder, the path must start with ../ in front instead of ./ since this file is in a subdirectory already. -->' >> ./PageContent/Resources/$FileName.html
        echo '    <!-- Leave the markers untouched! -->' >> ./PageContent/Resources/$FileName.html
        echo -n '<!--TitleMarker--><h1 style="text-align: center">' >> ./PageContent/Resources/$FileName.html
        echo "Project: $FileName" >> ./PageContent/Resources/$FileName.html
        echo '</h1>' >> ./PageContent/Resources/$FileName.html
        touch ./HeadContent/Resources/$FileName.html
        echo '    <!-- Meta data (Title, keywords, and description should be changed for each page...) -->' >> ./HeadContent/Resources/$FileName.html
        echo "    <title>OSRC/$FileName</title>" >> ./HeadContent/Resources/$FileName.html
        echo '    <meta charset="utf-8">' >> ./HeadContent/Resources/$FileName.html
        echo '    <meta name="viewport" content="width=device-width, initial-scale=1">' >> ./HeadContent/Resources/$FileName.html
        echo '    <meta name="Keywords" content="">' >> ./HeadContent/Resources/$FileName.html
        echo '    <meta name="Description" content="">' >> ./HeadContent/Resources/$FileName.html
        echo '    <link rel="icon" href="../Images/Common/Icon.png" type="image/x-icon">' >> ./HeadContent/Resources/$FileName.html
        echo '    <!-- Google font(s) -->' >> ./HeadContent/Resources/$FileName.html
        echo '    <link href="https://fonts.googleapis.com/css?family=Spectral+SC|Vollkorn" rel="stylesheet">' >> ./HeadContent/Resources/$FileName.html
        echo '    <!-- Style -->' >> ./HeadContent/Resources/$FileName.html
        echo '    <!-- Style sheets are managed by the construct.sh scipt, if you need to add another style sheet do it here for this page, of in the construct script for all pages or for Dark/Light pages separately-->' >> ./HeadContent/Resources/$FileName.html
        echo '    <!-- PageStyleDark.css (Leave this comment here for the Construct script to find where to insert style sheets) -->' >> ./HeadContent/Resources/$FileName.html
        echo '    <!-- Animation -->' >> ./HeadContent/Resources/$FileName.html
      else
        echo 'Creating regular page'
        touch ./PageContent/$FileName.html
        touch ./HeadContent/$FileName.html
        echo '    <!-- Meta data (Title, keywords, and description should be changed for each page...) -->' >> ./HeadContent/$FileName.html
        echo "    <title>OSRC/$FileName</title>" >> ./HeadContent/$FileName.html
        echo '    <meta charset="utf-8">' >> ./HeadContent/$FileName.html
        echo '    <meta name="viewport" content="width=device-width, initial-scale=1">' >> ./HeadContent/$FileName.html
        echo '    <meta name="Keywords" content="">' >> ./HeadContent/$FileName.html
        echo '    <meta name="Description" content="">' >> ./HeadContent/$FileName.html
        echo '    <link rel="icon" href="./Images/Common/Icon.png" type="image/x-icon">' >> ./HeadContent/$FileName.html
        echo '    <!-- Google font(s) -->' >> ./HeadContent/$FileName.html
        echo '    <link href="https://fonts.googleapis.com/css?family=Spectral+SC|Vollkorn" rel="stylesheet">' >> ./HeadContent/$FileName.html
        echo '    <!-- Style -->' >> ./HeadContent/$FileName.html
        echo '    <!-- Style sheets are managed by the construct.sh scipt, if you need to add another style sheet do it here for this page, of in the construct script for all pages or for Dark/Light pages separately-->' >> ./HeadContent/$FileName.html
        echo '    <!-- PageStyleDark.css (Leave this comment here for the Construct script to find where to insert style sheets) -->' >> ./HeadContent/$FileName.html
        echo '    <!-- Animation -->' >> ./HeadContent/$FileName.html
      fi
    fi
  fi
fi

# Opening file
if [[ $Head == true ]]
then
  FileName="$FileName.html"
  if [[ $Project == true ]]
  then
    Path="./HeadContent/Projects"
  else
    if [[ $Archived == true ]]
    then
      Path="./HeadContent/Archived"
    else
      if [[ $Article == true ]]
      then
        Path="./HeadContent/Resources"
      else
        Path="./HeadContent"
      fi
    fi
  fi
else
  if [[ $Description == true ]]
  then
    FileName="D-$FileName"
    if [[ $Project == true ]]
    then
      Path="./PageContent/Projects/Description"
      if [[ ! -e $Path/$FileName ]]
      then
        if [[ -e ./PageContent/Projects/A-${FileName:2:250}.html ]]
        then
          echo 'Error: The project is archived or halted! Please use -a instesd of -p or resume it and try again!'
          exit
        else
          if [[ -e ./PageContent/Projects/${FileName:2:250}.html ]]
          then
            echo 'Creating description file! (You can remove this file anytime with -u option.)'
            touch $Path/$FileName
          else
            echo 'Fatal: Project does not exist!'
            exit
          fi
        fi
      fi
    else
      if [[ $Archived == true ]]
      then
        Path="./PageContent/Archived/Description"
        if [[ ! -e $Path/$FileName ]]
        then
          if [[ -e ./PageContent/Archived/A-${FileName:2:250}.html ]]
          then
            echo 'Error: The project is unarchived! Please use -p instesd of -a and try again!'
            exit
          else
            if [[ -e ./PageContent/Archived/${FileName:2:250}.html ]]
            then
              echo 'Creating description file! (You can remove this file anytime with -u option.)'
              touch $Path/$FileName
            else
              echo 'Fatal: Project does not exist!'
              exit
            fi
          fi
        fi
      else
        if [[ $Article == true ]]
        then
          Path="./PageContent/Resources/Description"
          if [[ ! -e $Path/$FileName ]]
          then
            if [[ -e ./PageContent/Resources/A-${FileName:2:250}.html ]]
            then
              echo 'Error: The article is archived! Please unarchive it and try again!'
              exit
            else
              if [[ -e ./PageContent/Resources/${FileName:2:250}.html ]]
              then
                echo 'Creating description file! (You can remove this file anytime with -u option.)'
                touch $Path/$FileName
              else
                echo 'Fatal: Project does not exist!'
                exit
              fi
            fi
          fi
        fi
      fi
    fi
  else
    FileName="$FileName.html"
    if [[ $Project == true ]]
    then
      Path="./PageContent/Projects"
    else
      if [[ $Archived == true ]]
      then
        Path="./PageContent/Archived"
      else
        if [[ $Article == true ]]
        then
          Path="./PageContent/Resources"
        else
          Path="./PageContent"
        fi
      fi
    fi
  fi
fi
if [[ -f $Path/$FileName ]]
then
  gedit $Path/$FileName&
else
  if [[ -f $Path/A-$FileName ]]
  then
    if [[ $Archived == true ]]
    then
      echo 'Fatal: The project is unarchived! Try -p instead of -a option!'
      exit
    else
      if [[ $Project == true ]]
      then
        echo 'Fatal: The project is archived or halted! Try -a instead of -p option, or resume it then try again!'
        exit
      else
        echo 'Fatal: The article is archived! Unarchive it then try again!'
        exit
      fi
    fi
  else
    echo 'Fatal: The file doesn not exist!'
    exit
  fi
fi

# interactive mode
if [[ $Head == true || $Description == true ]] # interactive editor is only for pages not headers nor description files...
then
  Input="exit"
else
  Input=""
fi
while [[ $Input != "exit" ]]
do
  clear
  for i in $Input
  do
    case $i in
      # Elements
       "h1" ) echo '<h1>  </h1>' >> $Path/$FileName
              ;;
      "h1c" ) echo '<h1 style="text-align: center">  </h1>' >> $Path/$FileName
              ;;
      "h1r" ) echo '<h1 style="text-align: right">  </h1>' >> $Path/$FileName
              ;;
       "h2" ) echo '<h2>  </h2>' >> $Path/$FileName
              ;;
      "h2c" ) echo '<h2 style="text-align: center">  </h2>' >> $Path/$FileName
              ;;
      "h2r" ) echo '<h2 style="text-align: right">  </h2>' >> $Path/$FileName
              ;;
        "p" ) echo '<p>  </p>' >> $Path/$FileName
              ;;
       "pc" ) echo '<p style="text-align: center">  </p>' >> $Path/$FileName
              ;;
       "pr" ) echo '<p style="text-align: right">  </p>' >> $Path/$FileName
              ;;
       "br" ) echo '<br>' >> $Path/$FileName
              ;;
        "d" ) echo '<div>  </div>' >> $Path/$FileName
              ;;
        "s" ) echo '<span>  </span>' >> $Path/$FileName # 
              ;;
      "img" ) echo '<img src="">' >> $Path/$FileName # image
              ;;
      [la]* ) echo '<a href="">  </a>' >> $Path/$FileName # link
              ;;
       "t" ) echo '<table></table>' >> $Path/$FileName # image-link
              ;;
       "th" ) echo '<th></th>' >> $Path/$FileName # image-link
              ;;
       "tr" ) echo '<tr></tr>' >> $Path/$FileName # image-link
              ;;
       "td" ) echo '<td></td>' >> $Path/$FileName # image-link
              ;;
      # Shortcuts
       "tp" ) echo '<div class="TranslucentPanel"><div class="PanelArea">' >> $Path/$FileName # Open Translucent panel
              ;;
      "tpc" ) echo '</div></div>' >> $Path/$FileName # Close Translucent panel
              ;;
       "il" ) echo '<a href=""><img src=""></a>' >> $Path/$FileName # image-link
              ;;
      "dll" ) echo '<div class="Centered">' >> $Path/$FileName # Descriptive Link List
              echo -n '  <a href="' >> $Path/$FileName
              echo -n " URL " >> $Path/$FileName
              echo '">' >> $Path/$FileName
              echo '    <div class="TranslucentPanel">' >> $Path/$FileName
              echo '      <div class="PanelArea">' >> $Path/$FileName
              echo -n '        <span class="ProjectList">' >> $Path/$FileName
              echo -n ' NAME ' >> $Path/$FileName
              echo '</span><br>' >> $Path/$FileName
              echo -n '        <span class="ProjectListDescription">' >> $Path/$FileName
              echo -n ' DESCRIOTION ' >> $Path/$FileName
              echo '</span>' >> $Path/$FileName
              echo '      </div>' >> $Path/$FileName
              echo '    </div>' >> $Path/$FileName
              echo '  </a>' >> $Path/$FileName
              echo '</div>' >> $Path/$FileName
              echo '<br>' >> $Path/$FileName
              ;;
     "dlli" ) echo '<div class="Centered">' >> $Path/$FileName # Descriptive Link List(projects page style)
              echo -n '  <a href="' >> $Path/$FileName
              echo -n " URL " >> $Path/$FileName
              echo '">' >> $Path/$FileName
              echo '    <div class="TranslucentPanel">' >> $Path/$FileName
              echo '      <div class="PanelArea">' >> $Path/$FileName
              echo '        <table style="border: 0px; padding: 0px; margin: 0px">' >> $Path/$FileName
              echo '          <tr style="border: 0px; padding: 0px; margin: 0px">' >> $Path/$FileName
              echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 75px">' >> $Path/$FileName
              echo -n '              <img style="width: 75px; height: 75px" src=" IMAGE-URL ">' >> $Path/$FileName
              echo '            </td>' >> $Path/$FileName
              echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 5px">' >> $Path/$FileName
              echo '            </td>' >> $Path/$FileName
              echo '            <td style="border: 0px; padding: 0px; margin: 0px">' >> $Path/$FileName
              echo -n '              <span class="ProjectList">' >> $Path/$FileName
              echo -n ' NAME ' >> $Path/$FileName
              echo '</span><br>' >> $Path/$FileName
              echo -n '              <span class="ProjectListDescription">' >> $Path/$FileName
              echo -n ' DESCRIOTION ' >> $Path/$FileName
              echo '</span>' >> $Path/$FileName
              echo '            </td>' >> $Path/$FileName
              echo '          </tr>' >> $Path/$FileName
              echo '        </table>' >> $Path/$FileName
              echo '      </div>' >> $Path/$FileName
              echo '    </div>' >> $Path/$FileName
              echo '  </a>' >> $Path/$FileName
              echo '</div>' >> $Path/$FileName
              echo '<br>' >> $Path/$FileName
              ;;
     "help" ) echo "p(r/c)            <p> (right/center)"
              echo "h1/h2(c/r)        <h1> or <h2> (center/right)"
              echo "br                <br>"
              echo "l/a               <a>"
              echo "d                 <div>"
              echo "s                 <span>"
              echo "img               <img>"
              echo "t                 <t>"
              echo "td                <th>"
              echo "th                <td>"
              echo "tr                <tr>"
              echo "tp                Open translucent panel"
                        echo "tpc               Close translucent panel"
              echo "il                image link"
              echo "dll               Descriptive link list"
              echo "dlli              Descriptive link list with image"
              echo ""
              echo "exit              exit the interactive editor"
              echo ""
              ;;
           *) : #unkown input do nothing
              ;;
    esac
  done
  read -p "Interactive editor online! Type help for list of commands: " Input
done
