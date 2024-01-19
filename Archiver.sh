#! /bin/bash

# This is an attempt to avoid building old projects, while not breaking existing links to other pages either, instead providing an automatically generated page with a link that leads to the archived project.
# When you have large repository(like hundreds or even thousands of projects), you can save time by not re-generating archived pages each time by running construct.sh script with -n option. You only need to re-generate archived pages if you change someting in the page layout(not the style, by updating css files you can change the style for all pages including archived pages but the layout) or you add/remove something in the main menu(that's why I opted for a separate projects page keeping the main menu fairly simple and constant), otherwise unnecessary to generate archived pages.
# Use this script to archive/unarchive projects... Understand that it may break links that are linked in manually.(generated links should be fine).

# Syntax: [Command] [filename1] [filename2] ... [filename n] or [Command] [option] [filename1] [filename2] ... [filename n]
# Archiver.sh also allows archiving/unarchiving/resuming a mixt list... projects and articles on the smae list.

# Finding roots
cd $(cd "$(dirname "$0")"; pwd -P)

if [[ $1 == "-u" ]] # unarchive/resume option
then
  Operation="Unarchive"
  shift
else
  if [[ $1 == "-h" ]] # Halt option (For projects that are not finished nor abandoned to avoid re-generating them...)
  then
    Operation="Halt"
    shift
  else
    Operation="Archive"
  fi
fi

if [[ -z $@ ]]
then
  echo "Fatal: No project specified"
  exit
else
  if [[ $1 == "--help" ]]
  then
    echo ""
    echo "This script works recursively, you can archive/halt/unarchive multiple pages at once."
    echo "Default operation: Archive project/article"
    echo ""
    echo "Options:"
    echo "-h                  Halt project"
    echo "-u                  Unarchive/resume project/article"
    echo ""
    exit
  fi
fi

if [[ $Operation == "Archive" ]]
then
  for i in $@
  do
    echo ''
    if [[ -f ./PageContent/Archived/A-$i.html && -f ./PageContent/Projects/A-$i.html ]]
    then
      echo "Resuming project $i before archiving..."
      mv ./PageContent/Projects/A-$i.html ./PageContent/Projects/$i.html
    fi
    # Archiving
    if [[ -f ./PageContent/Resources/$i.html ]]
    then
      echo "Archiving article $i..."
      mv ./PageContent/Resources/$i.html ./PageContent/Resources/A-$i.html
      continue
    else
      if [[ -f ./PageContent/Resources/A-$i.html ]]
      then
        echo "Archiving article $i..."
        echo "Warning: Article $i is already archived!"
        continue
      fi
    fi
    echo "Archiving project $i..."
    if [[ ! -f ./PageContent/Projects/$i.html ]]
    then
      if [[ -f ./PageContent/Archived/$i.html && -f ./HeadContent/Archived/$i.html ]]
      then
        if [[ ! -f ./HeadContent/Projects/$i.html ]]
        then
          echo "Project $i was never unarchived! (It must have been created with -na option instead of -np...)"
          continue
        fi
      else
        if [[ ! -f ./HeadContent/Projects/$i.html && ! -f ./HeadContent/Archived/$i.html && ! -f ./PageContent/Projects/Description/D-$i && ! -f ./PageContent/Archived/Description/D-$i ]]
        then
          echo "Error: There is no project $i!"
          continue
        fi
      fi
    fi
    if [[ -f ./PageContent/Projects/$i.html ]]
    then
      if [[ -f ./PageContent/Archived/A-$i.html ]]
      then
        rm ./PageContent/Archived/A-$i.html
      fi
      mv ./PageContent/Projects/$i.html ./PageContent/Archived
      touch ./PageContent/Projects/A-$i.html
      echo '<h1 style="text-align: center">Welcome!</h1>' > ./PageContent/Projects/A-$i.html
      echo '<div class="Centered">' >> ./PageContent/Projects/A-$i.html
      echo '  <div class="TransparentWindow">' >> ./PageContent/Projects/A-$i.html
      echo '    <h2 style="text-align: center">Page has been archived, but you can find it:</h2>' >> ./PageContent/Projects/A-$i.html
      echo -n '    <a href="' >> ./PageContent/Projects/A-$i.html
      echo -n "../Archived/$i.html" >> ./PageContent/Projects/A-$i.html
      echo '"><h1 style="text-align: center">Here</h1></a>' >> ./PageContent/Projects/A-$i.html
      echo '    <h2 style="text-align: center">This means that this project is finished/failed/abandoned, thus no longer under development, but still available on this site.</h2>' >> ./PageContent/Projects/A-$i.html
      echo '    <p style="text-align: center">This is an automatically generated placeholder page designed to avoid a 404 error in case someone shared the link, instead provide you with a link to the archived project.</p>' >> ./PageContent/Projects/A-$i.html
      echo '  </div>' >> ./PageContent/Projects/A-$i.html
      echo '</div>' >> ./PageContent/Projects/A-$i.html
      # Adapting references
      for n in $(ls ./PageContent)
      do
        if [[ -f ./PageContent/$n ]] # Only search in files
        then
          if [[ ! -z $(cat ./PageContent/$n | grep "\./Projects/$i.html") && -z $(echo $n | grep Projects.html) ]] # don't search in projects.html, it's gonna be re-generated...
          then
            echo "Page $n contains reference to ./Projects/$i.html --> Switching reference to ./Archived/$i.html"
            sed -i "s/\.\/Projects\/${i}.html/\.\/Archived\/${i}.html/g" ./PageContent/$n
          fi
        fi
      done
      for n in $(ls ./PageContent/Archived)
      do
        if [[ -f ./PageContent/Archived/$n && $n != $i.html ]] # Only search in files except $i.html
        then
          if [[  ! -z $(cat ./PageContent/Archived/$n | grep "\.\./Projects/$i.html") ]]
          then
            echo "Page Archived/$n contains reference to ../Projects/$i.html --> Switching reference to ./$i.html"
            sed -i "s/\.\.\/Projects\/${i}.html/\.\/${i}.html/g" ./PageContent/Archived/$n
          fi
        fi
      done
      for n in $(ls ./PageContent/Projects)
      do
        if [[ -f ./PageContent/Projects/$n && $n != A-$i.html ]] # Only search in files except A-$i.html
        then
          if [[  ! -z $(cat ./PageContent/Projects/$n | grep "\./$i.html") ]]
          then
            echo "Page Projects/$n contains reference to ./$i.html --> Switching reference to ../Archived/$i.html"
            sed -i "s/\.\/${i}.html/\.\.\/Archived\/${i}.html/g" ./PageContent/Projects/$n
          fi
        fi
      done
      if [[  ! -z $(cat ./PageContent/Archived/$i.html | grep "\"\./") ]]
      then
        echo "Page Archived/$i.html contains reference to ./ --> Switching reference to ../Projects/"
        sed -i "s/\"\.\//\"\.\.\/Projects\//g" ./PageContent/Archived/$i.html
      fi
      if [[  ! -z $(cat ./PageContent/Archived/$i.html | grep "\.\./Archived/") ]]
      then
        echo "Page Archived/$i.html contains reference to ../Archived/ --> Switching reference to ./"
        sed -i "s/\"\.\.\/Archived\//\"\.\//g" ./PageContent/Archived/$i.html
      fi
      # End of adaption
    else
      if [[ -f ./PageContent/Archived/$i.html ]]
      then
        echo "Warning: Project file $i.html is already archived!"
      else
        echo "Error: Project file $i.html does not exist! (The page will not be generated!)"
      fi
    fi
    if [[ -f ./PageContent/Projects/Description/D-$i ]]
    then
      mv ./PageContent/Projects/Description/D-$i ./PageContent/Archived/Description
    else
      if [[ -f ./PageContent/Archived/Description/D-$i ]]
      then
        echo "Warning: Project description file D-$i is already archived!"
      else
        echo "Warning: Project description file D-$i does not exist! (Without this the project won't appear at the projects.html)"
      fi
    fi
    if [[ -f ./HeadContent/Projects/$i.html ]]
    then
      cp ./HeadContent/Projects/$i.html ./HeadContent/Archived
    else
        echo "Error: Project head file $i.html does not exist! (The page may not be created!)"
    fi
  done
else
  if [[ $Operation == "Halt" ]]
  then
    for i in $@
    do
      # Halting
      echo ""
      echo "Halting $i..."
      if [[ -f ./PageContent/Projects/$i.html ]]
      then
        if [[ -f ./HeadContent/Projects/$i.html ]]
        then
          if [[ ! -f ./HeadContent/Archived/$i.html ]]
          then
            cp ./HeadContent/Projects/$i.html ./HeadContent/Archived/$i.html
          fi
          mv ./PageContent/Projects/$i.html ./PageContent/Projects/A-$i.html
          if [[ ! -f ./PageContent/Archived/A-$i.html ]]
          then
            touch ./PageContent/Archived/A-$i.html
          fi
        else
          echo "Error: Project head file $i.html does not exist! (The page may not be created!) Aborting..."
          continue
        fi
      else
        if [[ -f ./PageContent/Projects/A-$i.html && -f ./PageContent/Archived/A-$i.html ]]
        then
          echo 'Project is already halted!'
        else
          if [[ -f ./PageContent/Projects/A-$i.html ]]
          then
            echo "Error: Project $i is archived! Halting only allpies to active projects!"
            continue
          else
            if [[ ! -f ./HeadContent/Projects/$i.html && ! -f ./HeadContent/Archived/$i.html && ! -f ./PageContent/Projects/Description/D-$i && ! -f ./PageContent/Archived/Description/D-$i ]]
            then
              echo "Error: Project $i does not exist!"
              continue
            else
              echo "Error: Project $i may have been created with -a option and never unarchived, or missing files!"
              continue
            fi
          fi
        fi
      fi
    done
  else
    for i in $@
    do
      echo ''
      if [[ -f ./PageContent/Projects/A-$i.html && -f ./PageContent/Archived/A-$i.html ]]
      then
        # Resuming
        echo "Resuming project $i..."
        mv ./PageContent/Projects/A-$i.html ./PageContent/Projects/$i.html
        continue
      fi
      # Unarchiving
      if [[ -f ./PageContent/Resources/A-$i.html ]]
      then
        echo "Unarchiving article $i..."
        mv ./PageContent/Resources/A-$i.html ./PageContent/Resources/$i.html
        continue
      else
        if [[ -f ./PageContent/Resources/$i.html ]]
        then
          echo "Unarchiving article $i..."
          echo "Warning: Article $i is already unarchived!"
          continue
        fi
      fi
      echo "Unarchiving $i..."
      if [[ -f ./PageContent/Archived/$i.html ]]
      then
        if [[ -f ./PageContent/Projects/A-$i.html ]]
        then
          rm ./PageContent/Projects/A-$i.html
        fi
        mv ./PageContent/Archived/$i.html ./PageContent/Projects
        touch ./PageContent/Archived/A-$i.html
        echo '<h1 style="text-align: center">Welcome!</h1>' > ./PageContent/Archived/A-$i.html
        echo '<div class="Centered">' >> ./PageContent/Archived/A-$i.html
        echo '  <div class="TransparentWindow">' >> ./PageContent/Archived/A-$i.html
        echo '    <h2 style="text-align: center">Good news! Page has been unarchived, and you can find it:</h2>' >> ./PageContent/Archived/A-$i.html
        echo -n '    <a href="' >> ./PageContent/Archived/A-$i.html
        echo -n "../Projects/$i.html" >> ./PageContent/Archived/A-$i.html
        echo '"><h1 style="text-align: center">Here</h1></a>' >> ./PageContent/Archived/A-$i.html
        echo '    <h2 style="text-align: center">This means that this project is resumed/re-started, thus no longer found in the archives.</h2>' >> ./PageContent/Archived/A-$i.html
        echo '    <p style="text-align: center">This is an automatically generated placeholder page designed to avoid a 404 error in case someone shared the link, instead provide you with a link to the project.</p>' >> ./PageContent/Archived/A-$i.html
        echo '  </div>' >> ./PageContent/Archived/A-$i.html
        echo '</div>' >> ./PageContent/Archived/A-$i.html
        # Adapting references
        for n in $(ls ./PageContent)
        do
          if [[ -f ./PageContent/$n ]] # Only search in files
          then
            if [[ ! -z $(cat ./PageContent/$n | grep "\./Archive/$i.html") && -z $(echo $n | grep Projects.html) ]] # don't search in projects.html, it's gonna be re-generated...
            then
              echo "Page $n contains reference to ./Archived/$i.html --> Switching reference to ./Projects/$i.html"
              sed -i "s/\.\/Archived\/${i}.html/\.\/Projects\/${i}.html/g" ./PageContent/$n
            fi
          fi
        done
        for n in $(ls ./PageContent/Archived)
        do
          if [[ -f ./PageContent/Archived/$n && $n != A-$i.html ]] # Only search in files except A-$i.html
          then
            if [[  ! -z $(cat ./PageContent/Archived/$n | grep "\./$i.html") ]]
            then
              echo "Page Archived/$n contains reference to ./$i.html --> Switching reference to ../Projects/$i.html"
              sed -i "s/\.\/${i}.html/\.\.\/Projects\/${i}.html/g" ./PageContent/Archived/$n
            fi
          fi
        done
        for n in $(ls ./PageContent/Projects)
        do
          if [[ -f ./PageContent/Projects/$n && $n != $i.html ]] # Only search in files except $i.html
          then
            if [[  ! -z $(cat ./PageContent/Projects/$n | grep "\.\./Archived/$i.html") ]]
            then
              echo "Page Projects/$n contains reference to ../Archived/$i.html --> Switching reference to ./$i.html"
              sed -i "s/\.\.\/Archived\/${i}.html/\.\/${i}.html/g" ./PageContent/Projects/$n
            fi
          fi
        done
        if [[  ! -z $(cat ./PageContent/Projects/$i.html | grep "\"\./") ]]
        then
          echo "Page Projects/$i.html contains reference to ./ --> Switching reference to ../Archived/"
          sed -i "s/\"\.\//\"\.\.\/Archived\//g" ./PageContent/Projects/$i.html
        fi
        if [[  ! -z $(cat ./PageContent/Projects/$i.html | grep "\.\./Projects/") ]]
        then
          echo "Page Projects/$i.html contains reference to ../Projects/ --> Switching reference to ./"
          sed -i "s/\"\.\.\/Projects\//\"\.\//g" ./PageContent/Projects/$i.html
        fi
        # End of adaption
      else
        if [[ ! -f ./PageContent/Archived/$i.html ]]
        then
          if [[ -f ./PageContent/Projects/$i.html && -f ./HeadContent/Projects/$i.html ]]
          then
            if [[ ! -f ./HeadContent/Archived/$i.html ]]
            then
              echo "Project $i was never archived!"
              continue
            fi
          else
            if [[ ! -f ./HeadContent/Projects/$i.html && ! -f ./HeadContent/Archived/$i.html && ! -f ./PageContent/Projects/Description/D-$i && ! -f ./PageContent/Archived/Description/D-$i ]]
            then
              echo "Error: There is no project $i!"
              continue
            fi
          fi
        fi
        if [[ -f ./PageContent/Projects/$i.html ]]
        then
          echo "Warning: Project file $i.html is already unarchived!"
        else
          echo "Error: Project file $i.html does not exist! (The page will not be generated!)"
        fi
      fi
      if [[ -f ./PageContent/Archived/Description/D-$i ]]
      then
        mv ./PageContent/Archived/Description/D-$i ./PageContent/Projects/Description
      else
        if [[ -f ./PageContent/Projects/Description/D-$i ]]
        then
          echo "Warning: Project description file D-$i is already unarchived!"
        else
          echo "Warning: Project description file D-$i does not exist! (Without this the project won't appear at the projects.html)"
        fi
      fi
      if [[ -f ./HeadContent/Archived/$i.html ]]
      then
        cp ./HeadContent/Archived/$i.html ./HeadContent/Projects
      else
        echo "Error: Project head file $i.html does not exist! (The page may not be created!)"
      fi
    done
  fi
fi
