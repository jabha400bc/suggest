#! /bin/bash
#####################################################################################################
export ANACONDA_URL='https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh'
export CODE_SERVER_URL='https://pankajbsn-public-images.s3.amazonaws.com/code-server-3.2.0-linux-x86_64.tar.gz'
export CODE_SERVER_URL_BKUP='https://pankajbsn-public-images.s3.amazonaws.com/code-server-3.2.0-linux-x86_64.tar.gz'
export VSCODE_PY_EXTN_URL='https://github.com/microsoft/vscode-python/releases/download/2020.3.71659/ms-python-release.vsix'
export VSCODE_PY_EXTN_URL_BKUP='https://pankajbsn-public-images.s3.amazonaws.com/ms-python-release.vsix'
#####################################################################################################
function install_softwares(){
    set -x \
    && make_software_home \
    && update_os \
    && create_setenv \
    && install_anaconda \
    && setup_myenv \
    && set +x
}
export SOFTWARE_HOME=/softwares
function make_software_home(){
    sudo mkdir -p $SOFTWARE_HOME \
    && sudo mkdir -p $SOFTWARE_HOME/data \
    && sudo chmod -R 777 $SOFTWARE_HOME
}
function update_os(){
    sudo apt update -y
}
function download_url_bkup(){
    MAIN_URL=$1
    BKUP_URL=$2
    wget --dns-timeout=2 $MAIN_URL
    RET_CODE=$?
    if [ $RET_CODE -eq 4 ]
    then
        echo "Not able to access github. Seems like firewall is blocking." \
        && echo "Trying alternate URL ..." \
        && wget $BKUP_URL
    fi
}
function install_anaconda(){
    ORIG_DIR=`pwd` \
    && cd $SOFTWARE_HOME \
    && download_anaconda \
    && rm -rf $SOFTWARE_HOME/anaconda3 \
    && bash Anaconda3-*-Linux-x86_64.sh -b -p $SOFTWARE_HOME/anaconda3 \
    && cd $ORIG_DIR
}
function add_condainit_to_bashrc(){
sudo cat <<-"EOF" >> ~/.bashrc
function condainit(){
. "${SOFTWARE_HOME}/anaconda3/etc/profile.d/conda.sh"
}
EOF
}
function download_anaconda(){
    if [ ! -f ${SOFTWARE_HOME}/Anaconda3-*-Linux-x86_64.sh* ]
    then
       wget $ANACONDA_URL
    fi
}
function setup_myenv(){
    . /softwares/setenv.sh \
    && conda create --name myenv --clone base \
    && conda activate myenv \
    && pip install --upgrade boto3
}
function resize_cloud9(){
    set -x \
    && SIZE=${1:-20} \
    && DISK=`lsblk | awk '{ if ($6 == "disk") {print($1);} }'` \
    && PART=`lsblk | awk '{ if ($6 == "part") {print(substr($1,3));} }'` \
    && sudo apt install -y jq \
    && INSTANCEID=$(curl http://169.254.169.254/latest/meta-data//instance-id) \
    && VOLUMEID=$(aws ec2 describe-instances --instance-id $INSTANCEID | jq -r .Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId) \
    && aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE \
    && while [ "$(aws ec2 describe-volumes-modifications --volume-id $VOLUMEID --filters Name=modification-state,Values="optimizing","completed" | jq '.VolumesModifications | length')" != "1" ]; do
        sleep 1
    done \
    && sudo growpart /dev/${DISK} 1 \
    && sudo resize2fs /dev/${PART} \
    && set +x
}
function create_setenv(){
cat << EOF > $SOFTWARE_HOME/setenv.sh && chmod 777 $SOFTWARE_HOME/setenv.sh
#! /bin/bash
. "${SOFTWARE_HOME}/anaconda3/etc/profile.d/conda.sh"  || echo anaconda not installed yet
conda activate myenv || echo conda myenv not yet setup
EOF
}