#################################################################################################

##              This WDL script marks the duplicates on input sorted BAMs                ##

#                              Script Options
#      -b        "Input BAM File"                            (Required)      
#      -s        "Name of the sample"                        (Optional)
#      -t        "Number of Threads"                         (Optional)
#      -S        "Path to the Sentieon Tool"                 (Required)
#      -O        "Directory for the Output"                  (Required)
#      -e        "Path to the environmental profile          (Required)
#      -d        "Debug Mode Toggle"                         (Optional)

#################################################################################################

task dedupTask {

   Array[File] InputBams                  # Input Sorted BAM File
   Array[File] InputBais                  # Input Sorted Bam Index File

   String SampleName                      # Name of the Sample

   String Sentieon                        # Variable path to Sentieon 

   String SentieonThreads                 # Specifies the number of thread required per run
   String DebugMode                       # Variable to check whether Debud Mode is on

   File DedupScript                       # Bash script that is called inside the WDL script
   File DedupEnvProfile                   # File containing the environmental profile variables

    command <<<
    set -euxo pipefail

    function sigusrhandler1()
    {
        echo "SIGUSR1 caught by shell script" 1>&2
        echo 30 > ./rc
        sync
    }

    function sigusrhandler2()
    {
        echo "SIGUSR2 caught by shell script" 1>&2
        echo 31 > ./rc
        sync
    }

    trap sigusrhandler1 SIGUSR1
    trap sigusrhandler2 SIGUSR2


    export LD_LIBRARY_PATH=""
    /bin/bash ${DedupScript} -b ${sep=',' InputBams} -s ${SampleName} -S ${Sentieon} -t ${SentieonThreads} -e ${DedupEnvProfile} ${DebugMode}

   >>>

   output {

      File OutputBams = "${SampleName}.aligned.sorted.deduped.bam"
      File OutputBais = "${SampleName}.aligned.sorted.deduped.bam.bai"

   }
}
