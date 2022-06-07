configfile:"config.yaml"
sc_tech=config["sc_tech"]
rule all:
    input:
      expand("bus/{sample}/output.bus", sample=config["sample"]),
      expand("bus/{sample}/matrix.ec", sample=config["sample"]),
      expand("bus/{sample}/transcripts.txt", sample=config["sample"])

rule get_SRA_by_accession:
    output:
        temp("reads/{accession}_1.fastq"),
        temp("reads/{accession}_2.fastq")
    params:
        args = "--split-files --progress --details",
        accession = "{accession}"
    log:
        "reads/{accession}.log"
    conda:
        "env.yml"
    shell:
        'mkdir -p {params.accession}_reads && '
        'fasterq-dump {params.args} {params.accession} -O reads/'


rule downloadKallistoIndex:
    output:
      "homo_sapiens/Homo_sapiens.GRCh38.96.gtf",
      "homo_sapiens/Homo_sapiens.GRCh38.cdna.all.fa",
      "homo_sapiens/transcriptome.idx",
      "homo_sapiens/transcripts_to_genes.txt"
    conda:
      "env.yml"
    shell:
      "curl https://github.com/pachterlab/kallisto-transcriptome-indices/releases/download/ensembl-96/homo_sapiens.tar.gz && \
      gunzip homo_sapiens.tar.gz"

rule kallistoBus:
    input:
      "homo_sapiens/Homo_sapiens.GRCh38.96.gtf",
      "homo_sapiens/Homo_sapiens.GRCh38.cdna.all.fa",
      "homo_sapiens/transcriptome.idx",
      "homo_sapiens/transcripts_to_genes.txt",
      expand("reads/{accession}_1.fastq", accession=config["accession"]),
      expand("reads/{accession}_2.fastq", accession=config["accession"])
    output:
      "bus/{sample}/output.bus",
      "bus/{sample}/matrix.ec",
      "bus/{sample}/transcripts.txt"
    conda:
      "env.yml"
    shell:
      "mkdir -p bus && \
      kallisto bus -i homo_sapiens/transcriptome.idx -o bus/ -x {sc_tech} reads/*.fastq"

rule bustools:
    input:
        bus="bus/{sample}/output.bus",
        matrix="bus/{sample}/matrix.ec",
        trns="bus/{sample}/transcripts.txt"
    output:
        count=""
    conda:
        "env.yml"
    shell:
        "mkdir -p count"
        "bustools sort -p {input.bus} | bustools count -o count/final.count"
