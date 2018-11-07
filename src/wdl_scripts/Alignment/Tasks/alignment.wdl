###########################################################################################

##              This WDL script performs alignment using BWA Mem                         ##

##                              Script Options
#       -t        "Number of Threads"                         (Optional)
#       -P        "Single Ended Reads specification"          (Required)
#       -l        "Left Fastq File"                           (Required)
#       -r        "Right Fastq File"                          (Optional)
#       -G        "Reference Genome"                          (Required)
#       -s        "Name of the sample"                        (Optional)
#       -S        "Path to the Sentieon Tool"                 (Required)
#       -g        "Group"                                     (Required)
#       -p        "Platform"                                  (Required)
#       -o        "BWA Extra Options"                         (Required)
#       -e        "Path to the environmental profile          (Required)
#       -d        "debug mode on/off                          (Optional: can be empty)

###########################################################################################

task alignmentTask {

   File InputRead1                 # Input Read File           
   String InputRead2               # Input Read File           
   String SampleName               # Name of the Sample
   String Group                    # starting read group string
   String Platform                 # sequencing platform for read group
   Boolean PairedEnd               # Variable to check if single ended or not

   File Ref                        # Reference Genome
   File RefAmb                     # reference file index
   File RefAnn                     # reference file index
   File RefBwt                     # reference file index
   File RefPac                     # reference file index
   File RefSa                      # reference file index

   String Sentieon                 # Path to Sentieon
   String SentieonThreads          # Specifies the number of thread required per run

   File AlignmentScript            # Bash script which is called inside the WDL script
   File AlignEnvProfile            # File containing the environmental profile variables
   String ChunkSizeInBases         # The -K option for BWA MEM
   String BWAExtraOptionsString    # String of extra options for BWA. This can be an empty string.

   String DebugMode                # Flag to enable Debug Mode

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

      /bin/bash ${AlignmentScript} -P ${PairedEnd} -g ${Group} -l ${InputRead1} -r ${InputRead2} -s ${SampleName} -p ${Platform} -G ${Ref} -o ${BWAExtraOptionsString} -K ${ChunkSizeInBases} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile} ${DebugMode}

   >>>

   output {

      File OutputBams = "${SampleName}.aligned.sorted.bam"
      File OutputBais = "${SampleName}.aligned.sorted.bam.bai"
   }
}

