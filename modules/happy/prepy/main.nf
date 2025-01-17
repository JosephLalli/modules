def VERSION = '0.3.14'

process HAPPY_PREPY {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::hap.py=0.3.14" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hap.py:0.3.14--py27h5c5a3ab_0':
        'quay.io/biocontainers/hap.py:0.3.14--py27h5c5a3ab_0' }"

    input:
    tuple val(meta), path(vcf), path(bed)
    tuple path(fasta), path(fasta_fai)

    output:
    tuple val(meta), path('*.vcf.gz')  , emit: preprocessed_vcf
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    pre.py \\
        $args \\
        -R $bed \\
        --reference $fasta \\
        --threads $task.cpus \\
        $vcf \\
        ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pre.py: $VERSION
    END_VERSIONS
    """
}
