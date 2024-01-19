#! /bin/bash

# Run this script for re-building all pages, or with -n option for skipping archived pages
# This code runs but it's NOT optimized for running efficiently on a "normal" system... Read the long comment for more on this!

# There is a way to make the code potentially run faster, and it's pretty easy, but it also breaks the structure of the generated code making it harder to de-bug... Take a look at the Build function it reads a few files over and over again while assembling different pages... Loading them to variables may be more efficient, since the PC wouldn't have to read so often from a slow drive. The modifications are in place but disabled by default, you only have to swictch over, by commenting and uncommenting a few lines before and within the Build function. (The only reason I left the old code in there by default, is that I made this for myself, and my entire operating system runs in RAM memory by means of my Volatizer project, thus my PC reads and writes from and to RAM anyway, so loading those files to variables wouldn't improve the performance what so ever, it would only make the generated code harder to debug, and those variables would use up that much more memory while building those pages... It simply wouldn't make sense for me, I let it be your accomplishment to hack this. ...or try Volatizer if you have enough RAM. :P)
# Note that the easy hack I proposed will do some improvement, on a normal system, but there's still room left for improvements... If you really want it to run as fast as possible use Volatizer it will really speed up all programs that read and/or write many and/or large files especially if you don't have a fast SSD...

# PreDefined variables
UpdateLimit=10
MainURL="." # !!! Change this to your own domain !!! (for github pages this should point to ".")


# Finding roots
T0=$(date +%s)
cd $(cd "$(dirname "$0")"; pwd -P)

if [[ $1 == "--help" ]]
then
  echo ""
  echo "This script builds the pages..."
  echo "Default operation: build all pages in both dark and light versions."
  echo ""
  echo "Options:"
  echo "-n                  Build new pages only. Skip archived and halted projects/articles"
  echo "-d                  Build dark pages only."
  echo ""
  exit
fi

for i in $@
do
  if [[ $i == "-n" ]] # No archives
  then
    NoArchives=$i
  fi
  if [[ $i == "-d" ]] # Dark pages only
  then
    DarkOnly=$i
  fi
done

# Clearing directory
if [[ ! -d ./www ]]
then
  mkdir ./www
else
  rm -Rf ./www
  mkdir ./www
fi

# Checking and uncompressing cache
mkdir ./Cache
if [[ -e ./CacheSum && -e ./Cache.tar.gz ]]
then
  if [[ $(cat ./CacheSum) == $(md5sum ./Cache.tar.gz | awk '{ print $1 }') ]]
  then
    tar -xpzf Cache.tar.gz
  else
    echo 'Error: Cache is damaged! -n option is unavailable... Generating everything!'
    NoArchives=""
    rm Cache.tar.gz
  fi
else
  echo 'Error: Cache.tar.gz and/or CacheSum not found -n option is unavailable... Generating everything!'
  NoArchives=""
fi

# Generating submenu pages (Projects.html, Resources.html)
./SubmenuGenerator.sh

# variables
HeadSource="./HeadContent"
Destination="./www"
DeepMenu=false
ArchiveFlag=false
DarkPageCount=0
LightPageCount=0
Variant="Dark" # Default style should be dark to avoid blinding people who browse at night with lights off...
PageStyleDark="CSS/PageStyleDark.css"
ContentStyleDark="CSS/ContentStyleDark.css"
PageStyleLight="CSS/PageStyleLight.css"
ContentStyleLight="CSS/ContentStyleLight.css"

# The echo commands are not functionally necessary, but they help understand how the HTML is broken up. (Take a look inside one of the generated HTML files in the www folder...)
#Beginning=$(cat ./Beginning) # Uncomment this
#HeadOver=$(cat ./HeadOver) # Uncomment this
#EndContent=$(cat ./EndContent) # Uncomment this
#PageBottom=$(cat ./PageBottom) # Uncomment this
#End=$(cat ./End) # Uncomment this

# Checking for non existent menupoints
LN=5
while [[ ! -z $(sed "${LN}q;d" ./Menu) ]]
do
  Line=$(sed "${LN}q;d" ./Menu)
  MenuItem=$(sed "${LN}q;d" ./Menu | awk '{ print $1 }')
  if [[ ! -f ./PageContent/$MenuItem && $MenuItem != "LatestUpdates.html" ]]
  then
    echo "Warning: Menu entry $MenuItem missing! Skipping..."
  fi
  LN=$(( $LN + 1 ))
done

function Build
{
  if [[ $Variant == "Dark" ]]
  then
    DarkPageCount=$(( $DarkPageCount + 1 ))
  else
    LightPageCount=$(( $LightPageCount + 1 ))
  fi
  touch $Destination/$File
  cat ./Beginning >> $Destination/$File #Comment this
#  echo $Beginning >> $Destination/$File #Uncomment this
  echo "" >> $Destination/$File
  echo "<!-- Beginning of head content -->" >> $Destination/$File
  echo "" >> $Destination/$File
  if [[ $DeepMenu == true ]]
  then
    if [[ $Variant == "Dark" ]]
    then
      # Deep-Dark
      LN=1
      while [[ -z $(sed "${LN}q;d" $HeadSource/$File | grep "PageStyleDark.css") ]]
      do
        echo "$(sed "${LN}q;d" $HeadSource/$File)" >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "../$PageStyleDark" >> $Destination/$File
      echo '">' >> $Destination/$File
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "../$ContentStyleDark" >> $Destination/$File
      echo '">' >> $Destination/$File
      LN=$(( $LN + 1 ))
      while [[ ! -z $(sed "${LN}q;d" $HeadSource/$File) ]]
      do
        echo $(sed "${LN}q;d" $HeadSource/$File) >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    else
      # Deep-Light
      # For crawler bots: Light pages should not be crawled, and should point to the same dark(canonical) page.
      echo "    <link rel=\"canonical\" href=\"./${File:2:250}\" />" >> $Destination/$File
      LN=1
      while [[ -z $(sed "${LN}q;d" $HeadSource/${File:2:250} | grep "PageStyleDark.css") ]]
      do
        echo "$(sed "${LN}q;d" $HeadSource/${File:2:250})" >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "../$PageStyleLight" >> $Destination/$File
      echo '">' >> $Destination/$File
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "../$ContentStyleLight" >> $Destination/$File
      echo '">' >> $Destination/$File
      LN=$(( $LN + 1 ))
      while [[ ! -z $(sed "${LN}q;d" $HeadSource/${File:2:250}) ]]
      do
        echo $(sed "${LN}q;d" $HeadSource/${File:2:250}) >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    fi
  else
    if [[ $Variant == "Dark" ]]
    then
      # Dark
      if [[ $File == "LatestUpdates.html" ]]
      then
        echo '    <meta name="googlebot" content="noindex">' >> $Destination/$File
        echo '    <meta name="robots" content="noindex">' >> $Destination/$File
      fi
      if [[ $File == "index.html" ]]
      then
        echo -n "    " >> $Destination/$File
        cat ./GoogleHTMLVerificationTag >> $Destination/$File
      fi
      LN=1
      while [[ -z $(sed "${LN}q;d" $HeadSource/$File | grep "PageStyleDark.css") ]]
      do
        echo "$(sed "${LN}q;d" $HeadSource/$File)" >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "$PageStyleDark" >> $Destination/$File
      echo '">' >> $Destination/$File
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "$ContentStyleDark" >> $Destination/$File
      echo '">' >> $Destination/$File
      LN=$(( $LN + 1 ))
      while [[ ! -z $(sed "${LN}q;d" $HeadSource/$File) ]]
      do
        echo $(sed "${LN}q;d" $HeadSource/$File) >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    else
      # Light
      # For crawler bots: Light pages should not be crawled, and should point to the same dark(canonical) page.
      if [[ ${File:2:250} == "index.html" ]]
      then
        echo "    <link rel=\"canonical\" href=\"$MainURL\" />" >> $Destination/$File
      else
        echo "    <link rel=\"canonical\" href=\"./${File:2:250}\" />" >> $Destination/$File
      fi
      if [[ ${File:2:250} == "LatestUpdates.html" ]]
      then
        echo '    <meta name="googlebot" content="noindex">' >> $Destination/$File
        echo '    <meta name="robots" content="noindex">' >> $Destination/$File
      fi
      LN=1
      while [[ -z $(sed "${LN}q;d" $HeadSource/${File:2:250} | grep "PageStyleDark.css") ]]
      do
        echo "$(sed "${LN}q;d" $HeadSource/${File:2:250})" >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "$PageStyleLight" >> $Destination/$File
      echo '">' >> $Destination/$File
      echo -n '    <link rel="stylesheet" type="text/css" href="' >> $Destination/$File
      echo -n "$ContentStyleLight" >> $Destination/$File
      echo '">' >> $Destination/$File
      LN=$(( $LN + 1 ))
      while [[ ! -z $(sed "${LN}q;d" $HeadSource/${File:2:250}) ]]
      do
        echo $(sed "${LN}q;d" $HeadSource/${File:2:250}) >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    fi
  fi

  echo "" >> $Destination/$File
  echo "<!-- End of head content -->" >> $Destination/$File
  echo "" >> $Destination/$File
  cat ./HeadOver >> $Destination/$File # Comment this
#  echo $HeadOver >> $Destination/$File # Uncomment this
  echo "" >> $Destination/$File
  echo "<!-- Beginning of page content -->" >> $Destination/$File
  echo "" >> $Destination/$File
  if [[ $Variant == "Dark" ]]
  then
    if [[ $ArchiveFlag == false ]]
    then
      cat $PageSource/$File >> $Destination/$File # these are changing with each page
    else
      cat $PageSource/A-$File >> $Destination/$File
    fi
  else
    # Making a temporary L-filename copy of the file to work with
    if [[ $ArchiveFlag == false ]]
    then
      cp $PageSource/${File:2:250} $PageSource/$File
    else
      cp $PageSource/A-${File:2:250} $PageSource/$File
    fi
    # Searching for links, and re-directing...
    if [[ -z $(echo $PageSource | grep Projects) && -z $(echo $PageSource | grep Archived) && -z $(echo $PageSource | grep Resources) ]] # For normal pages
    then
      for n in $(ls ./PageContent)
      do
        if [[ -f ./PageContent/$n ]] # Only search in files
        then
          if [[ ! -z $(cat $PageSource/$File | grep "\./$n") && $n != $File ]]
          then
            echo "Page $File contains reference to ./$n --> Switching reference to ./L-$n"
            sed -i "s/\.\/${n}/\.\/L-${n}/g" $PageSource/$File
          fi
        fi
      done
      for n in $(ls ./PageContent/Archived)
      do
        if [[ -f ./PageContent/Archived/$n ]] # Only search in files
        then
          if [[ ! -z $(cat $PageSource/$File | grep "\./Archived/$n") ]]
          then
            echo "Page $File contains reference to ./Archived/$n --> Switching reference to ./Archived/L-$n"
            sed -i "s/\.\/Archived\/${n}/\.\/Archived\/L-${n}/g" $PageSource/$File
          fi
        fi
      done
      for n in $(ls ./PageContent/Projects)
      do
        if [[ -f ./PageContent/Projects/$n ]] # Only search in files
        then
          if [[ ${n:0:2} == "A-" ]]
          then
            n=${n:2:250}
          fi
          if [[ ! -z $(cat $PageSource/$File | grep "\./Projects/$n") ]]
          then
            echo "Page $File contains reference to ./Projects/$n --> Switching reference to ./Projects/L-$n"
            sed -i "s/\.\/Projects\/${n}/\.\/Projects\/L-${n}/g" $PageSource/$File
          fi
        fi
      done
      for n in $(ls ./PageContent/Resources)
      do
        if [[ -f ./PageContent/Resources/$n ]] # Only search in files
        then
          if [[ ${n:0:2} == "A-" ]]
          then
            n=${n:2:250}
          fi
          if [[ ! -z $(cat $PageSource/$File | grep "\./Resources/$n") ]]
          then
            echo "Page $File contains reference to ./Resources/$n --> Switching reference to ./Resources/L-$n"
            sed -i "s/\.\/Resources\/${n}/\.\/Resources\/L-${n}/g" $PageSource/$File
          fi
        fi
      done
    else
      if [[ ! -z $(echo $PageSource | grep Projects) ]] # For project pages
      then
        for n in $(ls ./PageContent)
        do
          if [[ -f ./PageContent/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./$n") ]]
            then
              echo "Page Projects/$File contains reference to ../$n --> Switching reference to ../L-$n"
              sed -i "s/\.\.\/${n}/\.\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Archived)
        do
          if [[ -f ./PageContent/Archived/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Archived/$n") ]]
            then
              echo "Page Projects/$File contains reference to ../Archived/$n --> Switching reference to ../Archived/L-$n"
              sed -i "s/\.\.\/Archived\/${n}/\.\.\/Archived\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Projects)
        do
          if [[ -f ./PageContent/Projects/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\./$n") && $n != $File ]]
            then
              echo "Page Projects/$File contains reference to ./$n --> Switching reference to ./L-$n"
              sed -i "s/\.\/${n}/\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Resources)
        do
          if [[ -f ./PageContent/Resources/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Resources/$n") ]]
            then
              echo "Page Projects/$File contains reference to ../Resources/$n --> Switching reference to ../Resources/L-$n"
              sed -i "s/\.\.\/Resources\/${n}/\.\.\/Resources\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
      fi
      if [[ ! -z $(echo $PageSource | grep Archived) ]] # For archived pages
      then
        for n in $(ls ./PageContent)
        do
          if [[ -f ./PageContent/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./$n") ]]
            then
              echo "Page Archived/$File contains reference to ../$n --> Switching reference to ../L-$n"
              sed -i "s/\.\.\/${n}/\.\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Archived)
        do
          if [[ -f ./PageContent/Archived/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\./$n") && $n != $File ]]
            then
              echo "Page Archived/$File contains reference to ./$n --> Switching reference to ./L-$n"
              sed -i "s/\.\/${n}/\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Projects)
        do
          if [[ -f ./PageContent/Projects/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Projects/$n") ]]
            then
              echo "Page Archived/$File contains reference to ../Projects/$n --> Switching reference to ../Projects/L-$n"
              sed -i "s/\.\.\/Projects\/${n}/\.\.\/Projects\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Resources)
        do
          if [[ -f ./PageContent/Resources/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Resources/$n") ]]
            then
              echo "Page Archived/$File contains reference to ../Resources/$n --> Switching reference to ../Resources/L-$n"
              sed -i "s/\.\.\/Resources\/${n}/\.\.\/Resources\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
      fi
      if [[ ! -z $(echo $PageSource | grep Resources) ]] # For article pages
      then
        for n in $(ls ./PageContent)
        do
          if [[ -f ./PageContent/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./$n") ]]
            then
              echo "Page Resources/$File contains reference to ../$n --> Switching reference to ../L-$n"
              sed -i "s/\.\.\/${n}/\.\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Archived)
        do
          if [[ -f ./PageContent/Archived/$n ]] # Only search in files
          then
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Archived/$n") ]]
            then
              echo "Page Resources/$File contains reference to ../Archived/$n --> Switching reference to ../Archived/L-$n"
              sed -i "s/\.\.\/Archived\/${n}/\.\.\/Archived\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Projects)
        do
          if [[ -f ./PageContent/Projects/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\.\./Projects/$n") ]]
            then
              echo "Page Resources/$File contains reference to ../Projects/$n --> Switching reference to ../Projects/L-$n"
              sed -i "s/\.\.\/Projects\/${n}/\.\.\/Projects\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
        for n in $(ls ./PageContent/Resources)
        do
          if [[ -f ./PageContent/Resources/$n ]] # Only search in files
          then
            if [[ ${n:0:2} == "A-" ]]
            then
              n=${n:2:250}
            fi
            if [[ ! -z $(cat $PageSource/$File | grep "\./$n") && $n != $File ]]
            then
              echo "Page Resources/$File contains reference to ./$n --> Switching reference to ./L-$n"
              sed -i "s/\.\/${n}/\.\/L-${n}/g" $PageSource/$File
            fi
          fi
        done
      fi
    fi
    # Adding page content and cleaning up...
    cat $PageSource/$File >> $Destination/$File
    rm $PageSource/$File
  fi
  echo "" >> $Destination/$File
  echo "<!-- End of page content -->" >> $Destination/$File
  echo "" >> $Destination/$File
  cat ./EndContent >> $Destination/$File # Comment this
#  echo $EndContent >> $Destination/$File # Uncomment this
  echo "" >> $Destination/$File
  echo "<!-- Beginning of page title -->" >> $Destination/$File
  echo "" >> $Destination/$File
      if [[ $DeepMenu == true ]]
  then
    if [[ $Variant == "Dark" ]]
    then
      # Deep-Dark
      cat ./PageTop >> $Destination/$File
      sed -i "s/MENU/..\/Images\/Common\/M.svg/g" $Destination/$File
      sed -i "s/GENERATED_LINK/.\/L-$File/g" $Destination/$File
      sed -i "s/SUNMOON/..\/Images\/Dark\/Sun.svg/g" $Destination/$File
    else
      # Deep-Light
      cat ./PageTop >> $Destination/$File
      sed -i "s/MENU/..\/Images\/Common\/M.svg/g" $Destination/$File
      sed -i "s/GENERATED_LINK/.\/${File:2:250}/g" $Destination/$File
      sed -i "s/SUNMOON/..\/Images\/Light\/Moon.svg/g" $Destination/$File
    fi
  else
    if [[ $Variant == "Dark" ]]
    then
      # Dark
      cat ./PageTop >> $Destination/$File
      sed -i "s/MENU/.\/Images\/Common\/M.svg/g" $Destination/$File
      sed -i "s/GENERATED_LINK/.\/L-$File/g" $Destination/$File
      sed -i "s/SUNMOON/.\/Images\/Dark\/Sun.svg/g" $Destination/$File
    else
      # Light
      cat ./PageTop >> $Destination/$File
      sed -i "s/MENU/.\/Images\/Common\/M.svg/g" $Destination/$File
      sed -i "s/GENERATED_LINK/.\/${File:2:250}/g" $Destination/$File
      sed -i "s/SUNMOON/.\/Images\/Light\/Moon.svg/g" $Destination/$File
    fi
  fi
  echo "" >> $Destination/$File
  echo "<!-- End of page title -->" >> $Destination/$File
  echo "" >> $Destination/$File
  cat ./PageBottom >> $Destination/$File # Comment this
#  echo $PageBottom >> $Destination/$File # Uncomment this
  echo "" >> $Destination/$File
  echo "<!-- Beginning of Menu -->" >> $Destination/$File
  echo "" >> $Destination/$File
  echo '      <div class="Menu">' >> $Destination/$File
  echo '        <div class="TopOffset"></div>' >> $Destination/$File
  if [[ $DeepMenu == true ]]
  then
    if [[ $Variant == "Dark" ]]
    then
      # Deep-Dark
      LN=5
      while [[ ! -z $(sed "${LN}q;d" ./Menu) ]]
      do
        Line=$(sed "${LN}q;d" ./Menu)
        MenuItem=$(sed "${LN}q;d" ./Menu | awk '{ print $1 }')
        if [[ ! -f ./PageContent/$MenuItem && $MenuItem != "LatestUpdates.html" ]]
        then
          LN=$(( $LN + 1 ))
          continue
        fi
        echo -n '        <a href="' >> $Destination/$File
        if [[ ${MenuItem:0:4} == "http" ]]
        then
          echo -n "$MenuItem" >> $Destination/$File
        else
          if [[ $(echo $MenuItem | sed 's/.*\///') != $(echo $MenuItem | sed 's/\(.*\)\/.*/\1/') ]]
          then
            ItemName=$(echo $MenuItem | sed 's/.*\///')
            ItemPath=$(echo $MenuItem | sed 's/\(.*\)\/.*/\1/')
            if [[ $ItemPath == "Projects" && -f ./PageContent/Archived/$ItemName ]]
            then
              ItemPath="Archived"
            else
              if [[ $ItemPath == "Archived" && -f ./PageContent/Archived/A-$ItemName ]]
              then
                ItemPath="Projects"
              fi
            fi
            echo -n "../$ItemPath/" >> $Destination/$File
            echo -n "$ItemName" >> $Destination/$File
          else
            echo -n "../$MenuItem" >> $Destination/$File
          fi
        fi
        echo -n '"><div class="MenuPoint">' >> $Destination/$File
        NoSpace=true
        for i in $Line
        do
          if [[ $i != $MenuItem ]]
          then
            if [[ $NoSpace == true ]]
            then
              NoSpace=false
            else
              echo -n " " >> $Destination/$File
            fi
            echo -n "$i" >> $Destination/$File
          fi
        done
        echo '</div></a>' >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    else
      # Deep Light
      LN=5
      while [[ ! -z $(sed "${LN}q;d" ./Menu) ]]
      do
        Line=$(sed "${LN}q;d" ./Menu)
        MenuItem=$(sed "${LN}q;d" ./Menu | awk '{ print $1 }')
        if [[ ! -f ./PageContent/$MenuItem && $MenuItem != "LatestUpdates.html" ]]
        then
          LN=$(( $LN + 1 ))
          continue
        fi
        echo -n '        <a href="' >> $Destination/$File
        if [[ ${MenuItem:0:4} == "http" ]]
        then
          echo -n "$MenuItem" >> $Destination/$File
        else
          if [[ $(echo $MenuItem | sed 's/.*\///') != $(echo $MenuItem | sed 's/\(.*\)\/.*/\1/') ]]
          then
            ItemName=$(echo $MenuItem | sed 's/.*\///')
            ItemPath=$(echo $MenuItem | sed 's/\(.*\)\/.*/\1/')
            if [[ $ItemPath == "Projects" && -f ./PageContent/Archived/$ItemName ]]
            then
              ItemPath="Archived"
            else
              if [[ $ItemPath == "Archived" && -f ./PageContent/Archived/A-$ItemName ]]
              then
                ItemPath="Projects"
              fi
            fi
            echo -n "../$ItemPath/" >> $Destination/$File
            echo -n "L-$ItemName" >> $Destination/$File
          else
            echo -n "../L-$MenuItem" >> $Destination/$File
          fi
        fi
        echo -n '"><div class="MenuPoint">' >> $Destination/$File
        NoSpace=true
        for i in $Line
        do
          if [[ $i != $MenuItem ]]
          then
            if [[ $NoSpace == true ]]
            then
              NoSpace=false
            else
              echo -n " " >> $Destination/$File
            fi
            echo -n "$i" >> $Destination/$File
          fi
        done
        echo '</div></a>' >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    fi
  else
    if [[ $Variant == "Dark" ]]
    then
      # Dark
      LN=5
      while [[ ! -z $(sed "${LN}q;d" ./Menu) ]]
      do
        Line=$(sed "${LN}q;d" ./Menu)
        MenuItem=$(sed "${LN}q;d" ./Menu | awk '{ print $1 }')
        if [[ ! -f ./PageContent/$MenuItem && $MenuItem != "LatestUpdates.html" ]]
        then
          LN=$(( $LN + 1 ))
          continue
        fi
        echo -n '        <a href="' >> $Destination/$File
        if [[ ${MenuItem:0:4} == "http" ]]
        then
          echo -n "$MenuItem" >> $Destination/$File
        else
          if [[ $(echo $MenuItem | sed 's/.*\///') != $(echo $MenuItem | sed 's/\(.*\)\/.*/\1/') ]]
          then
            ItemName=$(echo $MenuItem | sed 's/.*\///')
            ItemPath=$(echo $MenuItem | sed 's/\(.*\)\/.*/\1/')
            if [[ $ItemPath == "Projects" && -f ./PageContent/Archived/$ItemName ]]
            then
              ItemPath="Archived"
            else
              if [[ $ItemPath == "Archived" && -f ./PageContent/Archived/A-$ItemName ]]
              then
                ItemPath="Projects"
              fi
            fi
            echo -n "./$ItemPath/" >> $Destination/$File
            echo -n "$ItemName" >> $Destination/$File
          else
            echo -n "./$MenuItem" >> $Destination/$File
          fi
        fi
        echo -n '"><div class="MenuPoint">' >> $Destination/$File
        NoSpace=true
        for i in $Line
        do
          if [[ $i != $MenuItem ]]
          then
            if [[ $NoSpace == true ]]
            then
              NoSpace=false
            else
              echo -n " " >> $Destination/$File
            fi
            echo -n "$i" >> $Destination/$File
          fi
        done
        echo '</div></a>' >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    else
      # Light
      LN=5
      while [[ ! -z $(sed "${LN}q;d" ./Menu) ]]
      do
        Line=$(sed "${LN}q;d" ./Menu)
        MenuItem=$(sed "${LN}q;d" ./Menu | awk '{ print $1 }')
        if [[ ! -f ./PageContent/$MenuItem && $MenuItem != "LatestUpdates.html" ]]
        then
          LN=$(( $LN + 1 ))
          continue
        fi
        echo -n '        <a href="' >> $Destination/$File
        if [[ ${MenuItem:0:4} == "http" ]]
        then
          echo -n "$MenuItem" >> $Destination/$File
        else
          if [[ $(echo $MenuItem | sed 's/.*\///') != $(echo $MenuItem | sed 's/\(.*\)\/.*/\1/') ]]
          then
            ItemName=$(echo $MenuItem | sed 's/.*\///')
            ItemPath=$(echo $MenuItem | sed 's/\(.*\)\/.*/\1/')
            if [[ $ItemPath == "Projects" && -f ./PageContent/Archived/$ItemName ]]
            then
              ItemPath="Archived"
            else
              if [[ $ItemPath == "Archived" && -f ./PageContent/Archived/A-$ItemName ]]
              then
                ItemPath="Projects"
              fi
            fi
            echo -n "./$ItemPath/" >> $Destination/$File
            echo -n "L-$ItemName" >> $Destination/$File
          else
            echo -n "./L-$MenuItem" >> $Destination/$File
          fi
        fi
        echo -n '"><div class="MenuPoint">' >> $Destination/$File
        NoSpace=true
        for i in $Line
        do
          if [[ $i != $MenuItem ]]
          then
            if [[ $NoSpace == true ]]
            then
              NoSpace=false
            else
              echo -n " " >> $Destination/$File
            fi
            echo -n "$i" >> $Destination/$File
          fi
        done
        echo '</div></a>' >> $Destination/$File
        LN=$(( $LN + 1 ))
      done
    fi    
  fi
  echo '        <div class="BottomOffset"></div>' >> $Destination/$File
  echo '      </div>' >> $Destination/$File
  echo "" >> $Destination/$File
  echo "<!-- End of Menu -->" >> $Destination/$File
  echo "" >> $Destination/$File
  cat ./End >> $Destination/$File # Comment this
#  echo $End >> $Destination/$File # Uncomment this
}

# Building Dark pages
PageSource="./PageContent"
echo "  Dark pages:"
for i in $(ls $PageSource)
do
  HeadSource="./HeadContent"
  PageSource="./PageContent"
  Destination="./www"
  DeepMenu=false
  if [[ -f $PageSource/$i ]]
  then
    File=$i
    if [[ ${File:0:2} != "L-" && -z $(echo $File | grep README) ]]
    then
      if [[ -f $HeadSource/$File ]]
      then
        echo "Building: $File"
        Build
      else
        echo "Error: $HeadSource/$File does not exit! Skipping page..."
      fi
    fi
  else
    HeadSource="$HeadSource/$i"
    PageSource="$PageSource/$i"
    Destination="$Destination/$i"
    DeepMenu=true
    mkdir $Destination
    for n in $(ls $PageSource) # This builds files 1 folder deeper...
    do
      ArchiveFlag=false
      if [[ -f $PageSource/$n ]]
      then
        File=$n
        if [[ ${File:0:2} != "L-" ]]
        then
          if [[ $NoArchives == "-n" ]] # only build new pages
          then
            if [[ -z $(echo $PageSource | grep Archive) && ${File:0:2} != "A-" ]]
            then
              if [[ -f $HeadSource/$File ]]
              then
                echo "Building: ${Destination:6:250}/$File"
                Build
              else
                echo "Error: $HeadSource/$File does not exit! Skipping page..."
              fi
            fi
          else
            if [[ ${File:0:2} == "A-" ]]
            then
              File="${File:2:250}"
              ArchiveFlag=true
            fi
            if [[ -f $HeadSource/$File ]]
            then
              if [[ $ArchiveFlag == true ]]
              then
                echo "Building: ${Destination:6:250}/A-$File"
              else
                echo "Building: ${Destination:6:250}/$File"
              fi
              Build
            else
              echo "Error: $HeadSource/$File does not exit! Skipping page..."
            fi
          fi
        fi
      fi
    done
  fi
done

# Clearing sitemap
if [[ -f "./www/Sitemap.txt" ]]
then
  echo -n "" > "./www/Sitemap.txt"
else
  touch "./www/Sitemap.txt"
fi

# Building Light pages
if [[ $DarkOnly != "-d" ]]
then
  Variant="Light"
  # Build light Pages
  PageSource="./PageContent"
  echo "  Light pages:"
  for i in $(ls $PageSource)
  do
    HeadSource="./HeadContent"
    PageSource="./PageContent"
    Destination="./www"
    DeepMenu=false
    if [[ -f $PageSource/$i ]]
    then
      File="L-$i"
      if [[ -z $(echo $File | grep README) ]]
      then
        if [[ -f $HeadSource/${File:2:250} ]]
        then
          echo "Building: $File"
          Build
          if [[ ${File:2:250} == "index.html" ]]
          then
            echo "$MainURL" >> "./www/Sitemap.txt" # Sitemap entry
            echo "$MainURL/L-index.html" >> "./www/Sitemap.txt" # Sitemap entry
          else
            echo "$MainURL/${Destination:6:10000}${File:2:250}" >> "./www/Sitemap.txt" # Sitemap entry
            echo "$MainURL/${Destination:6:10000}$File" >> "./www/Sitemap.txt" # Sitemap entry
          fi
        else
          echo "Error: $HeadSource/${File:2:250} does not exit! Skipping page..."
        fi
      fi
    else
      HeadSource="$HeadSource/$i"
      PageSource="$PageSource/$i"
      Destination="$Destination/$i"
      DeepMenu=true
      for n in $(ls $PageSource) # This builds files 1 folder deeper...
      do
        ArchiveFlag=false
        if [[ -f $PageSource/$n ]]
        then
          File="L-$n"
          if [[ $NoArchives == "-n" ]] # only build new pages
          then
            if [[ -z $(echo $PageSource | grep Archive) && ${File:2:2} != "A-" ]]
            then
              if [[ -f $HeadSource/${File:2:250} ]]
              then
                echo "Building: ${Destination:6:250}/$File"
                Build
                echo "$MainURL/${Destination:6:10000}/${File:2:250}" >> "./www/Sitemap.txt" # Sitemap entry
                echo "$MainURL/${Destination:6:10000}/$File" >> "./www/Sitemap.txt" # Sitemap entry
              else
                echo "Error: $HeadSource/${File:2:250} does not exit! Skipping page..."
              fi
            fi
          else
            if [[ ${File:2:2} == "A-" ]]
            then
              File="L-${File:4:250}"
              ArchiveFlag=true
            fi
            if [[ -f $HeadSource/${File:2:250} ]]
            then
              if [[ $ArchiveFlag == true ]]
              then
                echo "Building: ${Destination:6:250}/A-$File"
              else
                echo "Building: ${Destination:6:250}/$File"
              fi
              Build
              echo "$MainURL/${Destination:6:10000}/${File:2:250}" >> "./www/Sitemap.txt" # Sitemap entry
              echo "$MainURL/${Destination:6:10000}/$File" >> "./www/Sitemap.txt" # Sitemap entry
            else
              echo "Error: $HeadSource/${File:2:250} does not exit! Skipping page..."
            fi
          fi
        fi
      done
    fi
  done
fi

# Adding custom pages
cp -R ./CustomPages/* ./www

# Creating directories for additional files
DirList="CSS Images Files"
function CreateDir
{
  if [[ ! -d $Dir ]]
  then
    mkdir $Dir
  fi
}
Dir="./www/"
for i in $DirList
do
  Dir="$Dir$i"
  CreateDir
  Dir="./www/"
  for n in $(ls -p ./$i | grep /)
  do
    Dir="$Dir/$i/$n"
    CreateDir
    Dir="./www/"
  done
done

# Adding files selectively
echo ""
echo 'Adding files selectively.'
OtherFileCount=0
function AddFile
{
  Used=false
  echo "Searching for: $File"
  for x in $(ls -p ./www | grep -v /)
  do
    if [[ ! -z $(cat ./www/$x | grep $File) ]]
    then
      Used=true
    fi
    if [[ $Used == true ]]
    then
      echo "Found in : ./www/$x -> Adding!"
      cp ./$Dir$File ./www/$Dir$File
      OtherFileCount=$(( $OtherFileCount + 1 ))
      break
    fi
  done
  if [[ $Used != true ]]
  then
    for y in $(ls -p ./www | grep /)
    do
      if [[ ! -z $(echo $y | grep Images) || ! -z $(echo $y | grep Files) ]]
      then
        continue
      fi
      for x in $(ls -p ./www/$y | grep -v /)
      do
        if [[ ! -z $(cat ./www/$y$x | grep $File) ]]
        then
          Used=true
        fi
        if [[ $Used == true ]]
        then
          echo "Found in : ./www/$x -> Adding!"
          OtherFileCount=$(( $OtherFileCount + 1 ))
          cp ./$Dir$File ./www/$Dir$File
          break
        fi
      done
      if [[ $Used == true ]]
      then
        break
      fi
    done
  fi
}
for i in $DirList
do
  for n in $(ls -p ./$i | grep -v /)
  do
    File=$n
    Dir="$i/"
    AddFile
  done
  for n in $(ls -p ./$i | grep /)
  do
    for m in $(ls -p ./$i/$n | grep -v /)
    do
      File=$m
      Dir="$i/$n"
      AddFile
    done
  done
done

if [[ $DarkOnly != "-d" ]]
then
  echo ""
  T1=$(date +%s)
  echo 'The following steps apply to final version only that is ready for upload. If you wanna see the page in your browser, you better skip this, but you need to re-run this script answering "y" to the next question if it is ready for upload!'
  sleep 0.2 # The question may be displayed before the warning without this when log is generated by running the script like Construct.sh | tee [logfile]
  read -p "Uploading? (Y/n)" Yy
  T2=$(date +%s)
  echo ""
else
  T1=$(date +%s)
  T2=$T1
  Yy=n
fi
UnchangedFileCount=0
DeletedFileCount=0
if [[ $Yy == [Yy]* ]]
then
  function Message
  {
    if [[ $MessageDisplayed == false ]]
    then
      echo ""
      echo 'The following files ware used before but no longger rquired.'
      echo 'Please make sure to remove them from the server.'
      MessageDisplayed=true
      if [[ -e ./DeletionList ]]
      then
        touch ./DeletionList
      fi
    fi
  }

  function CheckRef
  {
    if [[ ! -z $(cat ./PageTop | grep $y) ]] # Checking Menu
    then
      echo "Error: $y Was deleted. but the PageTop and PageTopDeep is using it! Please remove the reference, and run Construct.sh again with no options specified! (This may affect every page!)"
    fi
    if [[ ! -z $(cat ./Menu | grep $y) ]] # Checking Menu
    then
      echo "Error: $y Was deleted. but the Menu is using it! Please remove the reference, and run Construct.sh again with no options specified! (This may affect every page!)"
    fi
    for x in $(ls -p ./CSS | grep -v /) # Checking CSS
    do
      if [[ ! -z $(cat ./CSS/$x | grep $y) ]]
      then
        echo "Error: $y Was deleted. but CSS/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./HeadContent | grep -v /) # Checking HeadContent
    do
      if [[ ! -z $(cat ./HeadContent/$x | grep $y) ]]
      then
        echo "Error: $y Was deleted. but HeadContent/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./HeadContent/Archived | grep -v /) # Checking HeadContent/Archived
    do
      if [[ ! -z $(cat ./HeadContent/Archived/$x | grep $y) ]]
      then
       echo "Error: $y Was deleted. but PageContent/Archived/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./HeadContent/Projects | grep -v /) # Checking HeadContent/Projects
    do
      if [[ ! -z $(cat ./HeadContent/Projects/$x | grep $y) ]]
      then
        echo "Error: $y Was deleted. but HeadContent/Projects/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./PageContent | grep -v /) # Checking PageContent
    do
      if [[ ! -z $(cat ./PageContent/$x | grep $y) && $x != "L-Projects.html" ]]
      then
        echo "Error: $y Was deleted. but PageContent/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./PageContent/Archived | grep -v /) # Checking PageContent/Archived
    do
      if [[ ! -z $(cat ./PageContent/Archived/$x | grep $y) ]]
      then
        echo "Error: $y Was deleted. but PageContent/Archived/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
    for x in $(ls -p ./PageContent/Projects | grep -v /) # Checking PageContent/Projects
    do
      if [[ ! -z $(cat ./PageContent/Projects/$x | grep $y) ]]
      then
        echo "Error: $y Was deleted. but PageContent/Projects/$x is using it! Please remove the reference, and run Construct.sh again with no options specified!"
      fi
    done
  }

  MessageDisplayed=false
  for i in $(ls -p ./Cache | grep -v /)
  do
    if [[ ! -e ./www/$i ]]
    then
      # Removing deleted files from Cache
      Message
      echo "$i" | tee -a DeletionList
      DeletedFileCount=$(( $DeletedFileCount + 1 ))
      rm ./Cache/$i
      y=$i
      CheckRef
    fi
  done
  for i in $(ls -p ./Cache | grep /)
  do
    for n in $(ls -p ./Cache/$i | grep -v /)
    do
      if [[ ! -e ./www/$i$n ]]
      then
        if [[ $NoArchives == "-n" ]]
        then
          if [[ $i != "Archived/" && ! -f ./PageContent/${i}A-$n && ! -f ./PageContent/${i}A-${n:2:250} ]]
          then
            Message
            echo "$i$n" | tee -a DeletionList
            DeletedFileCount=$(( $DeletedFileCount + 1 ))
            rm ./Cache/$i$n
            y=$n
            if [[ ! -f ./PageContent/${i}A-$y ]]
            then
              CheckRef
            fi
          fi
        else
          Message
          echo "$i$n" | tee -a DeletionList
          DeletedFileCount=$(( $DeletedFileCount + 1 ))
          rm ./Cache/$i$n
          y=$n
          CheckRef
        fi
      fi
    done
  done
  for i in $(ls -p ./Cache | grep /)
  do
    for n in $(ls -p ./Cache/$i | grep /)
    do
      for m in $(ls -p ./Cache/$i$n | grep -v /)
      do
        if [[ ! -e ./www/$i$n$m ]]
        then
          Message
          echo "$i$n$m" | tee -a DeletionList
          DeletedFileCount=$(( $DeletedFileCount + 1 ))
          rm ./Cache/$i$n$m
          y=$m
          CheckRef
        fi
      done
    done
  done

  Dir="./www/"
  CDir="./Cache/"
  if [[ ! -d $CDir ]]
  then
    mkdir $CDir
  fi

  # Leaving changed and new only in www (saves upload time and bandwidth)
  echo ""
  echo 'Removing unchanged files. (This step saves upload time and bandwidth.)'
  function Compare
  {
    for m in $(ls -p $CDir | grep -v /)
    do
      if [[ -e $Dir$m ]]
      then
        if [[ $(cat $CDir$m) == $(md5sum $Dir$m | awk '{ print $1 }') ]]
        then
          echo "Removing: $Dir$m"
          UnchangedFileCount=$(( $UnchangedFileCount + 1 ))
          rm $Dir$m
        else
          echo $(md5sum $Dir$m | awk '{ print $1 }') > $CDir$m # updating modified file checksum
        fi
      fi
    done
  }

  Compare
  for i in $(ls -p ./Cache | grep /) # 1Dir deep
  do
    Dir="$Dir$i"
    CDir="$CDir$i"
    Compare
    Dir="./www/"
    CDir="./Cache/"
  done
  Dir="./www/"
  CDir="./Cache/"
  for i in $(ls -p ./Cache | grep /) # 2Dir deep
  do
    for n in $(ls -p ./Cache/$i | grep /)
    do
      Dir="$Dir$i$n"
      CDir="$CDir$i$n"
      Compare
      Dir="./www/"
      CDir="./Cache/"
    done
  done

  # Adding new files to Cache
  function AddNew
  {
    for m in $(ls -p $Dir | grep -v /)
    do
      if [[ ! -e $CDir$m ]]
      then
        touch $CDir$m
        echo $(md5sum $Dir$m | awk '{ print $1 }') > $CDir$m # Adding new file checksum
      fi
    done
  }

  AddNew
  for i in $(ls -p ./www | grep /) # 1Dir deep
  do
    Dir="$Dir$i"
    CDir="$CDir$i"
    if [[ ! -d $CDir ]]
    then
      mkdir $CDir
    fi
    AddNew
    Dir="./www/"
    CDir="./Cache/"
  done
  Dir="./www/"
  CDir="./Cache/"
  for i in $(ls -p ./www | grep /) # 2Dir deep
  do
    for n in $(ls -p ./www/$i | grep /)
    do
      Dir="$Dir$i$n"
      CDir="$CDir$i$n"
      if [[ ! -d $CDir ]]
      then
        mkdir $CDir
      fi
      AddNew
      Dir="./www/"
      CDir="./Cache/"
    done
  done

  # Cache compression and cleanup
  tar -cpzf Cache.tar.gz Cache
  if [[ ! -f ./CacheSum ]]
  then
    touch ./CacheSum
  fi
  echo $(md5sum ./Cache.tar.gz | awk '{ print $1 }') > ./CacheSum

  # Generating LatestUpdates.html
  echo ""
  HeadSource="./HeadContent"
  PageSource="./PageContent"
  Destination="./www"
  DeepMenu=false
  ArchiveFlag=false
  Variant="Dark"
  File=LatestUpdates.html
  touch $PageSource/$File

  KeepUpdate=$(date +%Y%m%d%H%M%S)
  CurrentUpdate="./Updates/$KeepUpdate"
  touch $CurrentUpdate
  echo '<p style="text-align: center">Generated at: ISOTIME (ISO 8601 format >> YYYY-MM-DDThh:mm:ssTZD)</p>' >> $CurrentUpdate #ISOTIME marker Will be injected later...
  echo '<div class="TranslucentPanel">' >> $CurrentUpdate
  echo '  <div class="PanelArea">' >> $CurrentUpdate
  echo '    <h2>Updated pages:</h2>' >> $CurrentUpdate
  for i in $(ls -p ./www | grep -v /)
  do
    if [[ $(echo  $i  | sed 's/.*\.//') == "html" ]]
    then
      if [[ ${i:0:2} != "L-" && $i != "LatestUpdates.html" ]]
      then
        echo -n '    <a href="' >> $CurrentUpdate
        echo -n "./$i" >> $CurrentUpdate
        echo -n '"><span class="Link">' >> $CurrentUpdate
        echo -n $i | sed 's/\.[^.]*$//' >> $CurrentUpdate
        echo '    </span></a><br>' >> $CurrentUpdate
      fi
    fi
  done
  for i in $(ls -p ./www | grep /)
  do
    for n in $(ls -p ./www/$i | grep -v /)
    do
      if [[ $(echo  $n  | sed 's/.*\.//') == "html" ]]
      then
        if [[ ${n:0:2} != "L-" ]]
        then
          echo -n '    <a href="' >> $CurrentUpdate
          echo -n "./$i$n" >> $CurrentUpdate
          echo -n '"><span class="Link">' >> $CurrentUpdate
          echo -n $i$n | sed 's/\.[^.]*$//' >> $CurrentUpdate
          echo '    </span></a><br>' >> $CurrentUpdate
        fi
      fi
    done
  done
  echo '  <br>' >> $CurrentUpdate
  echo '  </div>' >> $CurrentUpdate
  echo '</div>' >> $CurrentUpdate


  echo '<h1 style="text-align: center">Latest Updates</h1>' >> $PageSource/$File
  cat $CurrentUpdate >> $PageSource/$File
  echo '    <h2>Note:</h2>' >> $PageSource/$File
  echo '<p>This page is automatically generated by the "Construct.sh" script every time something on the site is modified.<br>It serves the purpose of showing activity to our contributors who regularly donate, and fans who read everything we produce.</p>' >> $PageSource/$File
  echo '    <p>--> The script we use to generate pages will automatically attach every modified page, so if we modify the menu, or general page layout, or the cache is deleted/corrupted(in which case all pages are re-built) that modification will affect all pages, thus all pages will be linked in here.<br>--> Update report will be generated, but no pages will be linked in if the, css style sheet or files ware changed, but no pages ware modified.<br>--> Archiving/unarchiving a project, will affect Projects/something.html and Archived/something.html, one of which is an automatically generated placeholder page to avoid causing 404 errors on other sites that may point to the page.</p>' >> $PageSource/$File
  echo '<p style="text-align: right">All updated pages generated in: EXECTIME</p>' >> $PageSource/$File #EXECTIME marker will be injected later...
  if [[ ! -z $(ls ./Updates | grep -v $KeepUpdate) ]]
  then
    echo '<h1 style="text-align: center">Earlier Updates</h1>' >> $PageSource/$File
  fi
  UpdateCount=1
  for i in $(ls ./Updates | sort -Vr)
  do
    if [[ "./Updates/$i" != $CurrentUpdate ]]
    then
      cat ./Updates/$i >> $PageSource/$File
      KeepUpdate="$KeepUpdate $i"
      UpdateCount=$(( $UpdateCount + 1 ))
    fi
    if [[ $UpdateCount -eq $UpdateLimit ]]
    then
      break
    fi
  done
  for i in $(ls ./Updates | sort -Vr)
  do
    DeleteUpdate=true
    for n in $KeepUpdate
    do
      if [[ $i == $n ]]
      then
        DeleteUpdate=false
      fi
    done
    if [[ $DeleteUpdate == true ]]
    then
      rm ./Updates/$i
    fi
  done

  if [[ -f $HeadSource/$File ]]
  then
    echo "Building: $File"
    Build
  else
    echo "Error: $HeadSource/$File does not exit! Skipping page..."
  fi
  if [[ $DarkOnly != "-d" ]]
  then
    Variant="Light"
    File=L-LatestUpdates.html
    if [[ -f $HeadSource/${File:2:250} ]]
    then
      echo "Building: $File"
      Build
    else
      echo "Error: $HeadSource/$File does not exit! Skipping page..."
    fi
  fi
  rm $PageSource/${File:2:250}
fi

rm -R ./Cache
# Calculating and injecting EXECTIME and ISOTIME
T3=$(date +%s)
T=$(( $T1 - $T0 ))
TT=$(( $T3 - $T2 ))
T=$(( $T + $TT ))
TMinutes=$(( $T / 60 ))
TSeconds=$(( $T % 60 ))
ExecutionTime="${TMinutes}m ${TSeconds}s"
ISOTime=$(date -uIs)
if [[ -f $CurrentUpdate ]]
then
  sed -i "s/ISOTIME/$ISOTime/g" $CurrentUpdate
fi
if [[ -f ./www/LatestUpdates.html ]]
then
  sed -i "s/EXECTIME/$ExecutionTime/g" ./www/LatestUpdates.html
  sed -i "s/ISOTIME/$ISOTime/g" ./www/LatestUpdates.html
fi
if [[ -f ./www/L-LatestUpdates.html ]]
then
  sed -i "s/EXECTIME/$ExecutionTime/g" ./www/L-LatestUpdates.html
  sed -i "s/ISOTIME/$ISOTime/g" ./www/L-LatestUpdates.html
fi


# Sumarizing
echo ""
echo 'Summary:'
echo "Dark page count: $DarkPageCount"
echo "Light page count: $LightPageCount"
echo "Other file count: $OtherFileCount"
echo "Execution time: $ExecutionTime"
echo "Finished at: $ISOTime"
if [[ $NoArchives != "-n" ]]
then
  echo "Total number of files: $(( $DarkPageCount + $LightPageCount + $OtherFileCount ))"
fi
if [[ $Yy == [Yy]* ]]
then
  echo ""
  echo "Files to upload: $(( $DarkPageCount + $LightPageCount + $OtherFileCount - $UnchangedFileCount ))"
  echo "Files to delete: $DeletedFileCount"
fi
