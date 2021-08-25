
################################################
################################################
#           APPLICATION MANAGER
################################################
################################################

## CREATE DIR FOR APPLICATION CONFIGURATION

mkdir -p /opt/appmngr/{conf,apps}
conf="/opt/appmngr/conf"
apps="/opt/appmngr/apps"
echo -e """[Unit]\nDescription=\n\n[Service]\nExecStart=\nKillMode=\nRestart=\n\n[Install]\nWantedBy=""" > /opt/appmngr/conf/example.service.file



systemctl daemon-reload

case $1 in

	-h|--help)
		
		echo """ 
	   options			    Description
___________________________________________________________________________

	-h,   --help			Display help message.
	-d,   --disable <app>		Disable application on startup.
	-e,   --enable <app>		Enable application on startup.
	-ed,  --edit <app>		Edit the application file.
	-i,   --info <app>		information of the application.
	-l,   --list [app]		List all applications status.
	-r,   --restart <app>		restart the application.
	-s,   --start <app>		start the application.
	-sa,  --startall		start all the enbaled application.
	-st,  --stop <app>		stop the application.
	-sta, --stopall			stop all the running application.
	-a,   --add			add the application.						


			"""
			;;


	-d|--disable)
			echo
			systemctl disable $2.service &> /dev/null ; if [ `echo $?` == 0 ];then echo $2.service Disabled;else echo $2.service Enabled;fi
			echo

			;;

	-e|--enable)
			echo
			systemctl enable $2.service &> /dev/null ; if [ `echo $?` == 0 ];then echo $2.service Enabled;else echo $2.service Disabled;fi
			echo

			;;

	-i|--info)
			echo
			cat $conf/$2.service	
			echo

			;;

	-l | --list)	
			rm -rf /tmp/.brmin
			echo "___________________________________________________________________________________________________________________" >> /tmp/.brmin
			echo "             APP             |   VERSION    |     ONBOOT     |    STATUS    |                 STARTED              |" >> /tmp/.brmin
			echo "_____________________________|______________|________________|______________|______________________________________|" >> /tmp/.brmin
			
			a=`ls -l /opt/appmngr/conf/*.service 2> /dev/null |awk '{print $9}'`
			b=`for i in $a;do basename $i;done`  
			
			for i in $b
			do 
				name=`echo $i`
				version=`grep version $conf/$i|awk -F= '{print $2}'`
				onboot=$(ls -l /etc/systemd/system/multi-user.target.wants/$i &> /dev/null ; if [ `echo $?` == 0 ];then echo Enabled;else echo Disabled;fi)
				status=`systemctl status $i|grep -i active|awk '{print $2}'`
				started=`systemctl status $i|grep -i active|awk  '{print $5,$6,$7,";",$9}'`
				if [ $status = inactive ];then started="";fi
				
				printf "%-28s %-14s %-2s %-10s %-14s %-39s \n"  $name  \|"     "$version \|"    " $onboot \|"    "$status \|"$started" >> /tmp/.brmin
				echo >> /tmp/.brmin
				echo "_____________________________|______________|________________|______________|______________________________________|" >> /tmp/.brmin
			done	

			cat /tmp/.brmin
			echo

			;;


	-r|--restart)		
			
			systemctl restart $2.service &> /dev/null ; if [ `echo $?` == 0 ];then echo $2.service restarted ;else echo Failed to restart $2.service, check journalct -xe ;fi

			;;

	-s|--start)
			systemctl start $2.service &> /dev/null ; if [ `echo $?` == 0 ];then echo $2.service started ;else echo Failed to start $2.service, check journalct -xe ;fi

			;;

	-sa|--startall)
			a=`ls -l /opt/appmngr/conf/*.service|awk '{print $9}'`
			services=`for i in $a;do basename $i;done`
			systemctl start $services &> /dev/null ; if [ `echo $?` == 0 ];then echo all services started ;else echo Failed to start all services , check journalct -xe ;fi

			;;

	-st|--stop)
			systemctl stop $2.service &> /dev/null ; if [ `echo $?` == 0 ];then echo $2.service stoped ;else echo Failed to stop $2.service, check journalct -xe ;fi
		
			;;

	-sta|--stopall)
			a=`ls -l /opt/appmngr/conf/*.service|awk '{print $9}'`
			services=`for i in $a;do basename $i;done`
			
			systemctl stop $services &> /dev/null ; if [ `echo $?` == 0 ];then echo all services stopped ;else echo Failed to stop all services , check journalct -xe ;fi

			;;

	-a|--add)
			clear
			echo
			read -p "creating configuration file for your application, please enter the name of your app without space, name: " "name"
			echo
			read -p "enter a description for the $name app: " "description"
			echo
			read -p "start $name app on boot? (y/n) " "boot"
			echo
			read -p "please insert your $name app executable command with arguments like, ( /usr/bin/sleep 100 ): " "exec"
			echo
			read -p "do you want to restart your $name app on failure automatically (y/n): " "failure"
			echo
			read -p "please specify the name of your $name app folder in /opt/appmngr/apps/ (if don't have leave it blank): " "environmentFile"
			if [ -z $environmentFile ];then path="";else path=$apps/$environmentFile && mkdir -p $apps/$environmentFile ; fi
			echo
			read -p "enter your app version: " "version"
			echo
			
			if [ $failure = y ]
			then
				restart=on-failure
			else
				restart=""
			fi


			echo -e """[Unit]\nDescription=$description\n\n[Service]\nExecStart=$exec\nKillMode=process\nRestart=$restart\nEnvironmentFile=$path\n\n[Install]\nWantedBy=multi-user.target\n\n#version=$version""" > /opt/appmngr/conf/$name.service

			ln -s /opt/appmngr/conf/$name.service /usr/lib/systemd/system/

			if [ `echo $?` == 0 ];then echo "your file created at $conf and is linked to /usr/lib/systemd/system " ;else echo Failed to create or link your configuration file please check $conf and /usr/lib/systemd/system ;fi

			if [ $boot = y ]
			then
				systemctl enable $name.service &> /dev/null
			else
				systemctl disable $name.service &> /dev/null
			fi
			
			
				;;
	-ed|--edit)
			vi $conf/$2.service
				
			;;
	*)
		
		echo """ 
	   options			    Description
___________________________________________________________________________

	-h,   --help			Display help message.
	-d,   --disable <app>		Disable application on startup.
	-e,   --enable <app>		Enable application on startup.
	-ed,  --edit <app>		Edit the application file.
	-i,   --info <app>		information of the application.
	-l,   --list [app]		List all applications status.
	-r,   --restart <app>		restart the application.
	-s,   --start <app>		start the application.
	-sa,  --startall		start all the enbaled application.
	-st,  --stop <app>		stop the application.
	-sta, --stopall			stop all the running application.
	-a,   --add			add the application.						


			"""
		;;
	

esac
