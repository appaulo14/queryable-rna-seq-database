# Table of Contents
TODO: INSERT TABLE OF CONTENTS HERE
# Purpose
Formally known as the Queryable RNA-Seq Database, this system is designed to simplify the process of RNA-seq analysis by providing the ability upload the result data from RNA-Seq analysis into a database, store it, and query it in many different ways. 
# Overview
The purpose of the system is to automate and simplify as much as possible the process of analyzing RNA-Seq results data by storing it in a database and providing many options for querying it.
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/overview_of_the_system.png" alt="Overview of the sytem" />
# Goals
* **Goal 1:** Provide a system through which Biologists can analyze their RNA-Seq results data, specifically differential expression tests, novel transcript discoveries, and assembled transcripts. 
* **Goal 2:** The system should allow the user to get meaningful results with minimal learning time. For this goal to be satisfied, two senior Biologists familiar with RNA-seq must approve the system.
 
# Features
## General Features
### Helpful Tips Integrated With the User Manual
To reduce the learning curve, helpful tips and links to relevant sections of the user manual and other external websites with important information such as the Cufflinks manual are distributed throughout the Queryable RNA-Seq Database.
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/helpful_information.png" alt="Page filled with helpful information" />
## Upload from Multiple Differential Programs
### Cuffdiff
### Trinity with EdgeR
### Generic Nucleotide Fasta Sequences
## Query Your Data
### General Query Features
###### Sort The Results Table
By clicking on the green arrows in the header of each table column, the table can be sorted in either ascending or descending order.
<table>
<caption align="bottom">A Table Sorted in Ascending Order By Transcript</caption>
<tr><td><img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/ascending_sort.png" alt="A Table Sorted in Ascending Order By Transcript" /></td></tr>
</table>
<table>
<caption align="bottom">A Table Sorted in Descending Order By Transcript</caption>
<tr><td><img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/descending_sort.png" alt="A Table Sorted in Descending Order By Transcript" /></td></tr>
</table>
###### Download Your Results as A Text File
Click the "Save to Disk" button to save your results table to a text file. The sorting order will be preserved. Flash is required for this feature to work.<br/> 
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/save_to_disk.png" alt="Download your results as a text file" />
###### View The Fasta Sequences For A Transcript
###### View Transcript Fasta Sequence Associated With a Gene
###### View Gene Ontology (GO) Term Information  
### Query Your Transcript Differential Expresssion Tests
### Query Your Gene Differential Expresssion Tests
### Query Your Transcript Isoforms
## Blast a Blast Database of Your Sequences
The Queryable RNA-Seq Database allows you to query your data using the Megablast program of Blastn, using TBlastn, or using TBlastx. These blast query pages have a large subset of the features and algorithm features available for these programs on the [main Blast website](http://blast.ncbi.nlm.nih.gov/Blast.cgi).
### (Megablast) Blastn Page
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/blastn.png" alt="The Megablast program of blastn" />
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/blastn_algorithm_settings.png" alt="Blastn's algorithm settings" />
### TBlastn Page
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/tblastn.png" alt="The tblastn program" />
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/tblastn_algorithm_settings.png" alt="TBlastn's algorithm settings" />
### TBlastx Page
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/tblastx.png" alt="The tblastx program" />
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/tblastx_algorithm_settings.png" alt="TBlastx's algorithm settings" />
### Results Page For All Three
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/blast_results_1.png" alt="The first part of the blast results page" />
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/blast_results_2.png" alt="The second part of the blast results page" />
<img src="https://raw.github.com/fatPerlHacker/queryable-rna-seq-database/master/wiki_images/blast_results_3.png" alt="The third part of the blast results page" />