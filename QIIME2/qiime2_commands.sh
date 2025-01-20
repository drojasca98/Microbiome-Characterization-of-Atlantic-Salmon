BLANK SCRIPTS
CIRCLES
QIIME2 Workflow

#### Atlantic Salmon data

## My working folder path: /mnt/mini1/work/drojas
##Data folder path: /mnt/fat1/circles-data/ftp-data/seq-dtu/DIRECTORY

## Advice
	Conduct all analyses in a screen
		New screen session: screen -S Qiime2
		detatch: ctrl-a d
		reattach: screen -r Qiime2
		kill: quit
		deattach and reattach here: screen -d Qiime2

## Go to working folder
cd /mnt/mini1/work/drojas/salmon/

## Start a screen session
screen -S qiime2

## Set TMPDIR
export TMPDIR=/mnt/mini1/work/drojas

## activate conda environment qiime2
conda activate qiime2

#### Quality filtering, trimming and construction of ASVs
## Import paired end sequences as .qza (with manifest.csv document as key: manifest- atlanticsalmon-5.csv)
qiime tools import --type SampleData[PairedEndSequencesWithQuality] --input-path ./manifest.csv --output-path atlanticsalmon-5.qza --input-format PairedEndFastqManifestPhred33

		->Created ARTIFACT atlanticsalmon-5.qza

## Summarize and visualize the qza - to check for where to truncate
qiime demux summarize --i-data atlanticsalmon-5.qza --o-visualization viz-atlanticsalmon-5.qzv

		->Created VISUALIZATION: viz-atlanticsalmon-5.qzv
		->visualize .qzv file at https://view.qiime2.org/ to determine where to truncate 


## denoise paired-end reads (quality filter and trimming)
qiime dada2 denoise-paired --i-demultiplexed-seqs ./atlanticsalmon-5.qza --p-trunc-len-f 260 --p-trunc-len-r 200 --p-max-ee-f 5 --p-max-ee-r 5 --o-table table-atlanticsalmon-5.qza --o-representative-sequences rep-seqs-atlanticsalmon-5.qza --o-denoising-stats stats-atlanticsalmon-5.qza --p-n-threads 10 --verbose

		->Created FeatureTable[Frequency]: 	table-atlanticsalmon-5.qza  
		->Created FeatureData[Sequence]: 	rep-seqs-atlanticsalmon-5.qza
		->Created SampleData[DADA2Stats]: 	stats-atlanticsalmon-5.qza

## Viewing denoising stats
qiime metadata tabulate --m-input-file stats-atlanticsalmon-5.qza --o-visualization denoising-stats-atlanticsalmon-5.qzv

		->Created VISUALIZATION:	ddenoising-stats-atlanticsalmon-5.qzv
		->visualize .qzv file at https://view.qiime2.org/ to determine where to truncate and download table in .csv format

#### Taxonomic classification of ASVs
## Download silva 138 releases
		seqs & taxnomy .qza files 
		https://docs.qiime2.org/2023.5/data-resources/#taxonomy-classifiers-for-use-with-q2-feature-classifier
		
## Assign taxnomy using vsearch
qiime feature-classifier classify-consensus-vsearch --i-query rep-seqs-atlanticsalmon-5.qza --i-reference-reads silva-138-99-seqs.qza --i-reference-taxonomy silva-138-99-tax.qza --o-classification tax-class-atlanticsalmon-5.qza --p-threads 15 --verbose --p-perc-identity 0.97
		
		optional: --p-perc-identity 0.97
		->Created FeatureData[Taxonomy]: tax-class-atlanticsalmon-5.qza
		
##Visualize Taxonomy artifact
qiime taxa barplot --i-table table-atlanticsalmon-5.qza --i-taxonomy tax-class-atlanticsalmon-5.qza --m-metadata-file metadata.tsv  --o-visualization tax-viz-atlanticsalmon-5.qzv


#### Phylogenetic analysis - alignment + phylogeny tools
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs-atlanticsalmon-5.qza --p-n-threads 10 --o-alignment atlanticsalmon-5-alignment.qza --o-masked-alignment masked-aligned-atlanticsalmon-5.qza --o-tree unrooted-tree-atlanticsalmon-5.qza --o-rooted-tree rooted-tree-atlanticsalmon-5.qza --verbose

		->Created FeatureData[AlignedSequence]: aligned-atlanticsalmon-5.qza
		->Created FeatureData[AlignedSequence]: masked-aligned-atlanticsalmon-5.qza
		->Created Phylogeny[Unrooted]: unrooted-tree-atlanticsalmon-5.qza
		->Created Phylogeny[Rooted]: rooted-tree-atlanticsalmon-5.qza

#### Diversity analysis
##  Visualize feature table to assess the degree of sampling depth
qiime feature-table summarize --i-table table-atlanticsalmon-5.qza --o-visualization viz-table-atlanticsalmon-5.qzv --m-sample-metadata-file metadata-atlanticsalmon-5.tsv

## Calculate core metrics
qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree-atlanticsalmon-5.qza --i-table table-atlanticsalmon-5.qza --p-sampling-depth 5000 --m-metadata-file metadata-atlanticsalmon-5.tsv --output-dir core-metrics-results-atlanticsalmon-5 --p-n-jobs-or-threads 2

		->Created FeatureTable[Frequency]: core-metrics-results-atlanticsalmon-5/rarefied_table.qza
		->Created SampleData[AlphaDiversity] % Properties('phylogenetic'): core-metrics-results-atlanticsalmon-5/faith_pd_vector.qza
		->Created SampleData[AlphaDiversity]: core-metrics-results-atlanticsalmon-5/observed_otus_vector.qza
		->Created SampleData[AlphaDiversity]: core-metrics-results-atlanticsalmon-5/shannon_vector.qza
		->Created SampleData[AlphaDiversity]: core-metrics-results-atlanticsalmon-5/evenness_vector.qza
		->Created DistanceMatrix % Properties('phylogenetic'): core-metrics-results-atlanticsalmon-5/unweighted_unifrac_distance_matrix.qza
		->Created DistanceMatrix % Properties('phylogenetic'): core-metrics-results-atlanticsalmon-5/weighted_unifrac_distance_matrix.qza
		->Created DistanceMatrix: core-metrics-results-atlanticsalmon-5/jaccard_distance_matrix.qza
		->Created DistanceMatrix: core-metrics-results-atlanticsalmon-5/bray_curtis_distance_matrix.qza
		->Created PCoAResults: core-metrics-results-atlanticsalmon-5/unweighted_unifrac_pcoa_results.qza
		->Created PCoAResults: core-metrics-results-atlanticsalmon-5/weighted_unifrac_pcoa_results.qza
		->Created PCoAResults: core-metrics-results-atlanticsalmon-5/jaccard_pcoa_results.qza
		->Created PCoAResults: core-metrics-results-atlanticsalmon-5/bray_curtis_pcoa_results.qza
		->Created Visualization: core-metrics-results-atlanticsalmon-5/unweighted_unifrac_emperor.qzv
		->Created Visualization: core-metrics-results-atlanticsalmon-5/weighted_unifrac_emperor.qzv
		->Created Visualization: core-metrics-results-atlanticsalmon-5/jaccard_emperor.qzv
		->Created Visualization: core-metrics-results-atlanticsalmon-5/bray_curtis_emperor.qzv

## Calculate Diversity Shannon index
qiime diversity alpha --i-table table-no-unnassigned.qza --p-metric shannon --o-alpha-diversity shannon-no-unassigned.qza

## Calculate Richness with Chao1 index
qiime diversity alpha --i-table table-no-unnassigned.qza --p-metric chao1 --o-alpha-diversity chao1-no-unassigned.qza


####Visualize Diversity artifacts
##Alpha diversity
qiime diversity alpha-group-significance  --i-alpha-diversity SampleData[AlphaDiversity] --m-metadata-file ./metadata.tsv --o-visualization VISUALIZATION

qiime diversity alpha-group-significance  --i-alpha-diversity ./core-metrics-results-atlanticsalmon-5/evenness_vector.qza --m-metadata-file ./metadata.tsv --o-visualization  atlanticsalmon-5-AGS-evenness.qzv --verbose

qiime diversity alpha-group-significance  --i-alpha-diversity ./core-metrics-results-atlanticsalmon-5/shannon_vector.qza --m-metadata-file ./metadata.tsv --o-visualization  atlanticsalmon-5-AGS-shannon.qzv --verbose

qiime diversity alpha-group-significance  --i-alpha-diversity ./core-metrics-results-atlanticsalmon-5/observed_otus_vector.qza --m-metadata-file ./metadata.tsv --o-visualization  atlanticsalmon-5-AGS-observedOTUs.qzv --verbose

qiime diversity alpha-group-significance  --i-alpha-diversity ./core-metrics-results-atlanticsalmon-5/faith_pd_vector.qza --m-metadata-file ./metadata.tsv --o-visualization  atlanticsalmon-5-AGS-faith-pd.qzv --verbose

##Beta diversity
qiime diversity beta-group-significance --i-distance-matrix ARTIFACT DistanceMatrix --m-metadata-file METADATA --m-metadata-column COLUMN  MetadataColumn[Categorical] --o-visualization VISUALIZATION --verbose

qiime diversity beta-group-significance --i-distance-matrix ./core-metrics-results-atlanticsalmon-5/jaccard_distance_matrix.qza --m-metadata-file ./metadata.tsv --m-metadata-column sample-type --o-visualization  atlanticsalmon-5-BGS-jaccards.qzv --verbose

####Visualization of PCoAs
qiime emperor plot --i-pcoa ARTIFACT --m-metadata-file METADATA --o-visualization VISUALIZATION

qiime emperor plot --i-pcoa ./core-metrics-results-atlanticsalmon-5/bray_curtis_pcoa_results.qza --m-metadata-file ./metadata.tsv --o-visualization atlanticsalmon-5-bray_curtis_pcoa_results.qzv 