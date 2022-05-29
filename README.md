# tf-vpnserver-linux-desktop
Terraform create an OpenVPN server on EC2 or Ubuntu and install a GUI Desktop on that instance accessible through RDP. Set ```DISTRO_EC2=true``` in ```variables.sh```and ```distro_ec2``` in ```variables.tf``` to true if your want an EC2 Linux based instance; set them to ```false```if you prefer Ubuntu.

A simple way to create an Openvpn server and install a GUI on the same machine. The ideia is to allow using the machine as a gateway for an Openvpn client or use the RDP client to access the machine and navigate the Internet using the machine. To create the machine in a different region other than us-east-1 just change the variable in variables.tf 

Personalize the instance by configuring variables.tf and variables.sh

You should have no need to change anything else. After running ```terraform apply```, and waiting close to 10 minutes, you can navigate to http://x.x.x.x:8888 to download the Openvpn config file and the generated certificates. [x.x.x.x is the elastic IP of the instance]
