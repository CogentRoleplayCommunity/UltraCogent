#! /bin/bash

# This script will generate a new Projects.html and Resources.html in the PageContent directory, adding a link to every project it finds in the PageContent/Projects folder... 
# This should be automatically called by the construct script...

# Generating Projects.html
if [[ -f ./PageContent/Projects.html ]]
then
  rm ./PageContent/Projects.html
fi
if [[ ! -z $(ls ./PageContent/Projects/Description) || ! -z $(ls -p ./PageContent/Archived/Description) ]]
then
  echo "Generating Projects.html"
  touch ./PageContent/Projects.html
  echo '<!-- This page is generated by the ProjectsGenerator.sh script which is automatically called by the Consturct.sh scipt. Do not bother manually editing it, it is re-generated each time... -->' > ./PageContent/Projects.html

  cd ./PageContent/Projects/Description
  List=$(ls | grep "D-*")
  cd ..
  cd ..
  cd ..

  if [[ ! -z $List ]]
  then
    echo '<h1 style="text-align: center">Our Projects</h1>' >> ./PageContent/Projects.html
    for i in $List
    do
      if [[ ! -e ./PageContent/Projects/${i:2:250}.html ]]
      then
        Category=$(grep "<!--CategoryMarker-->" ./PageContent/Projects/A-${i:2:250}.html | awk '{ print $2 }')
      else
        Category=$(grep "<!--CategoryMarker-->" ./PageContent/Projects/${i:2:250}.html | awk '{ print $2 }')
      fi
      if [[ -z $Category ]]
      then
        Category=Undefined
      fi
      # Dark version (light version is generated by construct.sh)
      echo '<div class="Centered">' >> ./PageContent/Projects.html
      echo -n '  <a href="./Projects/' >> ./PageContent/Projects.html
      echo -n "${i:2:250}.html" >> ./PageContent/Projects.html
      echo '">' >> ./PageContent/Projects.html
      echo '    <div class="TranslucentPanel">' >> ./PageContent/Projects.html
      echo '      <div class="PanelArea">' >> ./PageContent/Projects.html
      echo '        <table style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo '          <tr style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 75px">' >> ./PageContent/Projects.html
      echo -n '              <img style="width: 75px; height: 75px" src="./Images/ProjectPages/' >> ./PageContent/Projects.html
      if [[ ! -e ./Images/ProjectPages/C-$Category.svg ]]
      then
        echo -n "C-$Category.png" >> ./PageContent/Projects.html
      else
        echo -n "C-$Category.svg" >> ./PageContent/Projects.html
      fi
      echo '">' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 5px">' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo -n '              <span class="ProjectList">' >> ./PageContent/Projects.html
      if [[ ! -e ./PageContent/Projects/${i:2:250}.html ]]
      then
        Title="$(grep 'TitleMarker' ./PageContent/Projects/A-${i:2:250}.html)"
      else
        Title="$(grep 'TitleMarker' ./PageContent/Projects/${i:2:250}.html)"
      fi
      echo ${Title:49:300} >> ./PageContent/Projects.html
      echo '              </span><br>' >> ./PageContent/Projects.html
      echo -n '              <span class="ProjectListDescription">' >> ./PageContent/Projects.html
      cat ./PageContent/Projects/Description/$i >> ./PageContent/Projects.html
      echo '              </span>' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '          </tr>' >> ./PageContent/Projects.html
      echo '        </table>' >> ./PageContent/Projects.html
      echo '      </div>' >> ./PageContent/Projects.html
      echo '    </div>' >> ./PageContent/Projects.html
      echo '  </a>' >> ./PageContent/Projects.html
      echo '</div>' >> ./PageContent/Projects.html
      echo '<br>' >> ./PageContent/Projects.html
    done
  fi

  cd ./PageContent/Archived/Description
  List=$(ls | grep "D-*")
  cd ..
  cd ..
  cd ..

  if [[ ! -z $List ]]
  then
    echo '<h1 style="text-align: center">Our Archived Projects</h1>' >> ./PageContent/Projects.html
    for i in $List
    do
      Category=$(grep "<!--CategoryMarker-->" ./PageContent/Archived/${i:2:250}.html | awk '{ print $2 }')
      if [[ -z $Category ]]
      then
        Category=Undefined
      fi
      # Dark version (light version is generated by construct.sh)
      echo '<div class="Centered">' >> ./PageContent/Projects.html
      echo -n '  <a href="./Archived/' >> ./PageContent/Projects.html
      echo -n "${i:2:250}.html" >> ./PageContent/Projects.html
      echo '">' >> ./PageContent/Projects.html
      echo '    <div class="TranslucentPanel">' >> ./PageContent/Projects.html
      echo '      <div class="PanelArea">' >> ./PageContent/Projects.html
      echo '        <table style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo '          <tr style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 75px">' >> ./PageContent/Projects.html
      echo -n '              <img style="width: 75px; height: 75px" src="./Images/ProjectPages/' >> ./PageContent/Projects.html
      if [[ ! -e ./Images/ProjectPages/C-$Category.svg ]]
      then
        echo -n "C-$Category.png" >> ./PageContent/Projects.html
      else
        echo -n "C-$Category.svg" >> ./PageContent/Projects.html
      fi
      echo '">' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px; width: 5px">' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '            <td style="border: 0px; padding: 0px; margin: 0px">' >> ./PageContent/Projects.html
      echo -n '              <span class="ProjectList">' >> ./PageContent/Projects.html
      Title="$(grep 'TitleMarker' ./PageContent/Archived/${i:2:250}.html)"
      echo ${Title:49:300} >> ./PageContent/Projects.html
      echo '              </span><br>' >> ./PageContent/Projects.html
      echo -n '              <span class="ProjectListDescription">' >> ./PageContent/Projects.html
      cat ./PageContent/Archived/Description/$i >> ./PageContent/Projects.html
      echo '              </span>' >> ./PageContent/Projects.html
      echo '            </td>' >> ./PageContent/Projects.html
      echo '          </tr>' >> ./PageContent/Projects.html
      echo '        </table>' >> ./PageContent/Projects.html
      echo '      </div>' >> ./PageContent/Projects.html
      echo '    </div>' >> ./PageContent/Projects.html
      echo '  </a>' >> ./PageContent/Projects.html
      echo '</div>' >> ./PageContent/Projects.html
      echo '<br>' >> ./PageContent/Projects.html
    done
  fi
fi

# Generating Resources.html
if [[ -f ./PageContent/Resources.html ]]
then
  rm ./PageContent/Resources.html
fi
if [[ ! -z $(ls ./PageContent/Resources/Description) ]]
then
  echo "Generating Resources.html"
  touch ./PageContent/Resources.html
  echo '<!-- This page is generated by the ProjectsGenerator.sh script which is automatically called by the Consturct.sh scipt. Do not bother manually editing it, it is re-generated each time... -->' > ./PageContent/Resources.html

  cd ./PageContent/Resources/Description
  List=$(ls | grep "D-*")
  cd ..
  cd ..
  cd ..

  if [[ ! -z $List ]]
  then
    echo '<h1 style="text-align: center">Resources</h1>' >> ./PageContent/Resources.html
    for i in $List
    do
      # Dark version (light version is generated by construct.sh)
      echo '<div class="Centered">' >> ./PageContent/Resources.html
      echo -n '  <a href="./Resources/' >> ./PageContent/Resources.html
      echo -n "${i:2:250}.html" >> ./PageContent/Resources.html
      echo '">' >> ./PageContent/Resources.html
      echo '    <div class="TranslucentPanel">' >> ./PageContent/Resources.html
      echo '      <div class="PanelArea">' >> ./PageContent/Resources.html
      echo -n '        <span class="ProjectList">' >> ./PageContent/Resources.html
      if [[ ! -e ./PageContent/Resources/${i:2:250}.html ]]
      then
        Title="$(grep 'TitleMarker' ./PageContent/Resources/A-${i:2:250}.html)"
      else
        Title="$(grep 'TitleMarker' ./PageContent/Resources/${i:2:250}.html)"
      fi
      echo ${Title:49:300} >> ./PageContent/Resources.html
      echo '        </span><br>' >> ./PageContent/Resources.html
      echo -n '        <span class="ProjectListDescription">' >> ./PageContent/Resources.html
      cat ./PageContent/Resources/Description/$i >> ./PageContent/Resources.html
      echo '        </span>' >> ./PageContent/Resources.html
      echo '      </div>' >> ./PageContent/Resources.html
      echo '    </div>' >> ./PageContent/Resources.html
      echo '  </a>' >> ./PageContent/Resources.html
      echo '</div>' >> ./PageContent/Resources.html
      echo '<br>' >> ./PageContent/Resources.html
    done
  fi
fi
