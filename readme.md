G-Cut is used for segmenting individual neurons from neuron clusters. 
The software is written in Matlab(R2013b).

System requirements: 
Prerequisites: any system with a functional installation of Matlab
Recommend settings: 8 core CPU, 16GB and above RAM.

Installation: 
Download the gcut_source_code.zip, and uncompress it to desired destination.
We will call the destination installation_path. You need to add the 
installation_path to Matlab's search path by launching matlab, and (1) selecting
"set path" under Home tab, and using "Add Folder" to add installation_path
or (2) using command: addpath(installation_path) 

Third party dependencies:
Please download Matlab Tools for Network Analysis at
http://strategic.mit.edu/downloads.php?page=matlab_networks, and add the
routines to Matlab search path.

Usage:
----------------------------------general--------------------------------------
G-Cut takes as input an initial reconstruction of interconnected neuron cluster,
and segment the cluster into individual neurons. Currently, the accepted input
format is the swc format (see http://neuromorpho.org/myfaq.jsp. for more
information). User should also supply location of somas, obtainable via a
multitude of previously published methods. Multiple freely availabe softwares
can be used to render the file, most Vaa3D (vaa3d.org) and 
neuTube (http://www.neutracing.com/). 

Please be mindful when providing soma location in xyz coordinate format
(described below). Different software packages may set different coordinate
origins. It is recommended that the user validate consistency of coordinate
systems between the swc file and the soma coordinates. 
The authors suggest producing a swc file based on soma coordinates.
For example, if the user has two somas located at (3058.80054117, 2695.13645149,
27.0204870506) and (3405.51372501, 1796.63882945, 17.9294695441), a valid
swc file will look as following:
    0 274 3058.80054117 2695.13645149 27.0204870506 13.7277325535 -1
    1 274 3405.51372501 1796.63882945 17.9294695441 36.6107227682 -1
The swc files for the neuron cluster and the somas can then be rended with one
of the softwares mentioned above to ascertain coordinate system consistency.

Additional parameter can be parsed to G-Cut for more fine tuned behavior,
please see below.

-----------------------------------demo----------------------------------------
A few sample swc files are provided in installation_path/demo_data.
Running the script gcut_demo.m (located in installation_path folder) will generate
segmented neurons from the sample swc file, stored as swc files at 
installation_path/demo_result.

-----------------------------------API-----------------------------------------
To run G-Cut on your own data, use the script 
gcut_source_code/Neuron_split_sparse_beta.m.
If your machine has a minimum of 8 cores avaiable, you can use 
gcut_source_code/Neuron_solit_spare_sever_version.m, 
which runs the algorithm in parallel mode.

Both scripts takes the same arguments:
Neuron_split_spare_beta[server_version](input_data_dir, output_dir, 
                                        soma_option, 
                                        distribution_option, distribution_neurons_dir, 
                                        param_short_leaf_pruning, 
                                        param_fitness_pruning, 
                                        param_recon_dist) 
input_data_dir: 
     input data folder. must contain neuron cluster in swc format, and 
     corresponding text file with soma information. The swc file and text
     file should be named [cluster_name].swc and [cluster_name]_soma_ind.txt
     respectively. Multiple neuron clusters can exist in the input data
     folder, as long as their corresponding soma information files are
     present 
Note that if multiple neural clusters and their soma information files 
are present under input_data_dir, they will all be processed.

output_dir: 
     output folder. SWC file for segemented individual neurons are stored
     in this folder as [cluster_name]_[number].swc, where number ranges 
     between 1 and total number of neurons in the cluster

soma_option - input soma information file type:
0 - soma_index: The node number of somas in SWC file
                if node 5 and 23 are somas, the file should be written as:
                5
                23
1 - soma_location: The x,y,z locations of somas
                   if node 5 has coordinates (1, 2, 3) and node 23 has 
                   coordinates (4, 5, 6), the file should be written as:
                   1 2 3
                   4 5 6

distribution_option: 
     G-Cut replies on the statistical distribution of neuron morphological
     features to perform neuron segmentation. We derived such distributions
     for multiple brain regions, animal species and cell types, based on over 
     70,000 existing neuron reconstructions. Users can enter a string 
     indicating a pre-computed distribution (Please see 'GOF_list.xlsx' 
     for details. As an example, 'b7' indicates neocortex specific 
     distribution). Some users may be interested in brain regions specific
     to mouse. We have also derived mouse brain region specific distributions.
     To use those, go to source code of Neuron_split_sparse_beta.m, at line
     55, change "poly_para_set = importdata('GOF_default.mat')" to
     poly_para_set = importdata('GOF_mouse_default.mat'). Please refer to
     'GOF_mouse_list.xlsx' for details.
     Additionally, users can provide a set of reconstructed neurons 
     in .swc. The special distribution_option '0' indicates customized GOF
     distribution. See below.

distribution_neurons_dir:   
     When '0' is the distribution_option, swc files in the directory 
     distribution_neurons_dir will be used to compute a custome GOF 
     distribution. For any precomputed distributions, please enter ''. 

 param_short_leaf_pruning: 
    Noisy image stacks often result in strong presence of overly short
    neurites. Input a range between 0 - 1, to indicate the percentage of 
    neurites to prune by length. For example, an input of 0.1 causes the
    top 10% shortest leaf neurites to be pruned. If no short leaf neurite 
    pruning is wanted, enter [].

 param_fitness_pruning: 
    When an image stack contains neurite arising from a external soma, 
    it is possible for the resulting reconstruction to contain those alien
    neurites. We observe such neurites often exhibit GOF values unlikely
    in natually occuring neurons. This function use a threshold of GOF to 
    prun such erroneous neurites. The input paramenter range from
    0 ~ pi (in radians). If no GOF pruning is wanted, please enter [].

param_recon_dist: 
    This parameter is a place holder for a function under construction. 
    Please enter [];
