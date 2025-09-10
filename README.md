### **Introduction**

This application integrates the HLA*LA tool developed by Alexander Dilthey and team available at https://github.com/DiltheyLab/HLA-LA. The repository contains most dependencies that are required to run the app, but a few files need to be installed as they are pivotal to a succesfsul run. These files include the reference genome file, HLA-LA and Rscript.

The application is built to process CRAM/CRAI files and provide a excel compatible CSV file. If you need the entire CRAM file process, simply upload the file when prompted. However, if you need only a part of the CRAM file processed, uncomment the REGION variable in the file backend.sh and enter the region you wish to analyse. After adding the REGION variable, edit step one of the backend.sh script. The new command should now be **./samtools-env/bin/samtools  view -b -T $refgenome -o $BAM_FILE $CRAM_FILE $REGION**

### **Pre-requisites**
1. The app requires java to be pre-installed in order to function. If there is no java installed, it can be easily done so by running the command **sudo apt install openjdk-11-jdk -y**
2. The app requires python and pip to be pre-installed in order to call the app. Using pip, flask can be installed by the command **pip install flask**

The app is made for linux based systems i.e macOS and the commands do not work on Windows Powershell. It is recommended that both macOS and Windows users work on Visual Studio Code (VS Code) as it helps in keeping tab of all dependencies. VS code is free to download via https://code.visualstudio.com/. Windows users can initialise a wsl window through Ubuntu 22.04LTS.

### **Reference genome**

You can download the reference genome file using the link below https://drive.google.com/uc?export=download&id=1MtsSA9TTzHyUq82wshRisWap48c-cCkv. (File size: 3GB)

It is recommended to download the file in the same place as the cloned repository in order to avoid editing the backend script and any additional complications.

### **Recommended practice for downloading HLA-LA and Rscript**

Two additional libraries need to be added in order for the pipeline to function. These are HLA-LA available at https://github.com/DiltheyLab/HLA-LA and R-Studio to combine all results. It is recommended to install these via conda as it manages all dependencies and linking. 

Miniconda can be installed into the same directory as the cloned repository by following the below steps:
1. wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
2. bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
3. source $HOME/miniconda3/bin/activate
4. conda --version

### **HLA-LA installation and configuration**

HLA-LA can be installed via conda by the following steps:
1. conda config --add channels default
2. conda config --add channels conda-forge
3. conda config --add channels biconda
4. conda update conda
5. conda create -p /path/to/App/hlaenv -c bioconda hla-la
6. mkdir /path/to/App/hlaenv/opt/hla-la/graphs
7. cd /path/to/App/hlaenv/opt/hla-la/graphs

The data package stil needs to be installed and indexed in order to compare CRAM files with a pre-processed graph. This can be achieved by the following set of commands:

1. mkdir /path/to/App/hlaenv/opt/hla-la/graphs
2. cd /path/to/App/hlaenv/opt/hla-la/graphs
3. wget http://www.well.ox.ac.uk/downloads/PRG_MHC_GRCh38_withIMGT.tar.gz
4. tar -xvzf PRG_MHC_GRCh38_withIMGT.tar.gz
5. cd /path/to/App/hlaenv/opt/hla-la/src
6. wget https://www.dropbox.com/s/mnkig0fhaym43m0/reference_HLA_ASM.tar.gz
7. tar -xvzf reference_HLA_ASM.tar.gz
8. ../bin/HLA-LA --action prepareGraph --PRG_graph_dir ../graphs/PRG_MHC_GRCh38_withIMGT

The final step may take a while and requires atleast 40GB of free memory. Manual compilaton steps are available on the github page for HLA*LA at https://github.com/DiltheyLab/HLA-LA along with debugging steps if any errors are faced. Once the graph is prepared and indexed, activate the HLA-LA environment using the command conda activate /path/to/App/hlaenv.

### **RScript installation and configuration**
Renv can be set up by the following commands:
1. mkdir -p /path/to/App/Renv
2. conda create --prefix /path/to/App/Renv -c conda-forge r-base
3. conda activate /path/to/App/Renv
4. conda install -c -conda-forge r-tidyr r-diplyr
5. conda deactivate

### **Instructions to run the app**

Once the repository has been cloned and all packages have been installed and configured. From terminal run **python app_new**

This provides a message saying "running on http://127.0.0.1:5000" Click on this link and upload the CRAM file/files that require HLA calling along with /path/to/output directory. You can track progress by reading the commands on the terminal, keeping track of new files that are being added to the output direcotry or by running the command "top" in a new terminal window.

**NOTE:** If you install HLA-LA and Renv in a directory other than where you clone this repositry, the path to these tools need to be changed in the backend.sh script to point to the right files. Hence, installing the files in the same directory as the clone is recommended.
