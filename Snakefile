configfile:"config.yaml"
sc_tech=config["sc_tech"]
rule all:
    input:
      expand("quant/{sample}/abundance.h5", sample=config["sample"]),
      expand("quant/{sample}/abundance.tsv", sample=config["sample"]),
      expand("quant/{sample}/run_info.json", sample=config["sample"])

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

rule kallistoQuant:
    input:
      "homo_sapiens/Homo_sapiens.GRCh38.96.gtf",
      "homo_sapiens/Homo_sapiens.GRCh38.cdna.all.fa",
      "homo_sapiens/transcriptome.idx",
      "homo_sapiens/transcripts_to_genes.txt",
      r1="{sample}_R1.fastq.gz",
      r2="{sample}_R2.fastq.gz"
    output:
      "quant/{sample}/abundance.h5",
      "quant/{sample}/abundance.tsv",
      "quant/{sample}/run_info.json"
    conda:
      "env.yml"
    shell:
      "mkdir -p quant && \
      kallisto bus -i homo_sapiens/transcriptome.idx -o quant/{wildcards.sample} -x {sc_tech} {input.r1} {input.r2}"
