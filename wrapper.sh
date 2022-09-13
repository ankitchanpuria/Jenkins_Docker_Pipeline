#!/bin/bash

repo_dir="/root/jenkins_docker_pipeline/myrepo"
base_dir="/root/jenkins_docker_pipeline"

validate_pull_app_code ()
{
	if [ -d "$repo_dir" ] 
	then
	  # Take action if $repo_dir exists.
	  echo "Found myrepo ! Clearing out contents of myrepo"
	  rm -rf ${repo_dir}
	  cd $base_dir
	  git clone git@github.com:ankitchanpuria/myrepo.git
	  status=$?
	  if [ $status -eq 0 ] 
	  then
	  	echo "Directory contents cleared successfully, and pulled new application code."
	  	ls -lrt
	  	return 0
	  else
	  	echo "Failed to clear directory contents, exit code : $status"
	  	return 1
	  fi
	else 
		echo "$repo_dir doesnt exists, pulling from remote repository"
		cd $base_dir
		git clone git@github.com:ankitchanpuria/myrepo.git
		status=$?
	  	if [ $status -eq 0 ]; then
	  		echo "Git Clone Success !"
	  		ls -lrt
	  		return 0
	  	else
	  		echo "Failed to clone from git repo, exit code : $status"
	  		return 1
	  	fi
	fi
}

run_docker()
{
	
	docker_output=`docker ps -a`
	cont_id=`echo $docker_output|awk {'print $9'}`
	echo "Removing any existing docker"
	docker rm -f $cont_id
	docker_cmd="docker run -dit -p 8888:8080 tomcat:9.0"
	echo "Executing docker cmd:$docker_cmd"
	$docker_cmd
}

stage_app_code()
{
	docker ps -a
	docker_output=`docker ps -a`
	cont_id=`echo $docker_output|awk {'print $9'}`
	app_code=/root/jenkins_docker_pipeline/myrepo/addressbook-2.1.war
	echo "Moving app code to docker:${app_code}"
	docker cp ${app_code} ${cont_id}:/usr/local/tomcat/webapps
	if [ $? -eq 0 ]
	then
	echo "Docker has app code, please access the application through url below"
	echo "http://localhost:8888/addressbook-2.1/"
	fi

}

docker_image_build()
{
    echo "Getting inside:$repo_dir"
	cd $repo_dir
	echo "Building docker image"
	cmd="docker build --tag devops_project ."
	echo "Executing build cmd:$cmd"
	$cmd
	if [ $? -eq 0 ]
	then
		echo "Docker image build is success"
	else
		echo "Docker image build failed:Status:$?"
		exit 1
	fi

}

docker_image_container()
{

	echo "Getting image id"
	image_id=`docker images|grep devops_project|awk '{print $3}'`
	image_name=`docker images|grep devops_project|awk '{print $1}'`
	echo "Starting up a container with image_id:$image_id and image_name:$image_name."
	docker_cmd_image="docker run -dit -p 8000:8080 devops_project"
	echo "Executing docker cmd:$docker_cmd_image"
	$docker_cmd_image
	if [ $? -eq 0 ]
	then
		echo "Docker container on newly created image:$image_id,$image_name started successfully"
	else
		echo "Docker start container on newly created image($image_name) failed:Status:$?"
	fi
}

main ()
{
	args=$1
	if [ $args = "pull_app_code" ]
	then
		validate_pull_app_code
		if [ $? -eq 0 ]
		then
			echo "$1 , input operation success."
		else
			echo "Error Encountered during input operation:$1, exiting !"
			exit 1;
		fi

	elif [ $args = "run_docker" ]
	then
		run_docker
		if [ $? -eq 0 ]
		then
			echo "$1 , input operation success."
		else
			echo "Error Encountered during input operation:$1, exiting !"
			exit 1;
		fi
	elif [ $args = stage_app_code ]
	then
		stage_app_code
		if [ $? -eq 0 ]
		then
			echo "$1 , input operation success."
		else
			echo "Error Encountered during input operation:$1, exiting !"
			exit 1;
		fi
	elif [ $args = "docker_image_build" ]
		then
			docker_image_build
	elif [ $args = "docker_image_container" ]
		then 
			docker_image_container
	fi

}

main $1