#!/usr/bin/python

import getopt
import sys
from Bio import  SeqIO
import time
import os
import shutil
import pandas

__author__ = "Andriy Sheremet"

#Helper functions definitions


def parse_contigs_ind(f_name):
    """
    Returns sequences index from the input files(s)
    remember to close index object after use
    """
    handle = open(f_name, "rU")
    record_dict = SeqIO.index(f_name,"fasta")
    handle.close()
    return record_dict

#returning specific sequences and overal list
def retrive_sequence(contig_lst, rec_dic):
    """
    Returns list of sequence elements from dictionary/index of SeqIO objects specific to the contig_lst parameter
    """
    contig_seqs = list()
    #record_dict = rec_dic
    #handle.close()
    for contig in contig_lst:
        contig_seqs.append(rec_dic[contig].seq.tostring())
    return contig_seqs


def filter_seq_dict(key_lst, rec_dic):
    """
    Returns filtered dictionary element from rec_dic according to sequence names passed in key_lst
    """
    return { key: rec_dic[key] for key in key_lst }

def unique_scaffold_topEval(dataframe):
#returns pandas series object
    variables = list(dataframe.columns.values)
    scaffolds=dict()
    rows=list()

    for row in dataframe.itertuples():

        #if row[1]=='Ga0073928_10002560':
        if row[1] not in scaffolds:
            scaffolds[row[1]]=row
        else:
            if row[11]<scaffolds[row[1]][11]:
                scaffolds[row[1]]=row
    rows=scaffolds.values()
    #variables=['quid', 'suid', 'iden', 'alen', 'mism', 'gapo', 'qsta', 'qend', 'ssta', 'send', 'eval', 'bits']
    df = pandas.DataFrame([[getattr(i,j) for j in variables] for i in rows], columns = variables)
    return df

def usage():
    print "\nThis is the usage function\n"
#    print 'Usage: '+sys.argv[0]+' -i <input_file> [-o <output>] [-l <minimum length>]'
#    print 'Example: '+sys.argv[0]+' -i input.fasta -o output.fasta -l 100'

def main(argv):
    
    #default parameters
    mg_lst = []
    ref_lst = []
    e_val = 1e-5
    alen = 50.0
    iden = 95.0
    name= "output"
    fmt_lst = ["fasta"]
    supported_formats =["fasta", "csv"]
    iterations = 1
    alen_increment = 5.0
    iden_increment = 0.0
    blast_db_Dir = ""
    results_Dir = ""
    input_files_Dir = ""
    ref_out_0 = ""
    
             
    try:                                
        opts, args = getopt.getopt(argv, "r:m:n:e:a:i:f:h", ["reference=", "metagenome=", "name=", "e_value=", "alignment_length=", "identity=","format=", "iterations=", "alen_increment=", "iden_increment=", "help"])
    except getopt.GetoptError:          
        usage()                         
        sys.exit(2)                     
    for opt, arg in opts:                
        if opt in ("-h", "--help"):      
            usage()              
            sys.exit()                  
        elif opt in ("-r", "--reference"):
            if arg:
                ref_lst=arg.split(',')
                #infiles = arg
            print "Reference file(s)", ref_lst  
        elif opt in ("-m", "--metagenome"):
            if arg:
                mg_lst=arg.split(',')
                #infiles = arg
            print "Metagenome file(s)", mg_lst
            
        elif opt in ("-f", "--format"):
            if arg:
                fmt_lst=arg.split(',')
                #infiles = arg
            print "Output format(s)", fmt_lst
        
        elif opt in ("-n", "--name"):
            if arg.strip():              
                name = arg
            print "Project name", name 
            
        elif opt in ("-e", "--e_value"):
            try:
                e_val = float(arg)
            except:
                print "\nERROR: Please enter numerical value as -e parameter (using default: 1e-5)"
                usage()
                sys.exit(1)
            print "E value", e_val
            
        elif opt in ("-a", "--alignment_length"):
            try:
                alen = float(arg)
            except:
                print "\nERROR: Please enter an numerical value as -alen parameter (using default: 50.0)"
                usage()
                sys.exit(1)
            print "Alignment length", alen           
            
        elif opt in ("-i", "--identity"):
            try:
                iden = float(arg)
            except:
                print "\nERROR: Please enter an numerical value as -iden parameter (using default: 95.0)"
                usage()
                sys.exit(1)
            print "Alignment length", iden    
            
        elif opt in ("--iterations"):
            try:
                iterations = int(arg)
            except:
                
                print "\nWARNING: Please enter integer value as --iterations parameter (using default: 1)"

            print "Iterations: ", iterations  
            
        elif opt in ("--alen_increment"):
            
            try:
                alen_increment = float(arg)
            except:
                print "\nWARNING: Please enter numerical value as --alen_increment parameter (using default: )", alen_increment

            print "Alignment length increment: ", alen_increment 
 
        elif opt in ("--iden_increment"):
            
            try:
                iden_increment = float(arg)
            except:
                print "\nWARNING: Please enter numerical value as --iden_increment parameter (using default: )", iden_increment

            print "Alignment length increment: ", iden_increment 
            
    for ref_file in [x for x in ref_lst if x]:
        try:
            #
            with open(ref_file, "rU") as hand_ref:
                pass
        except:
            print "\nERROR: Reference File(s) ["+ref_file+"] doesn't exist"
            usage()
            sys.exit(1)
            
    for mg_file in [x for x in mg_lst if x]:
        try:
            #
            with open(mg_file, "rU") as hand_mg:
                pass
        except:
            print "\nERROR: Metagenome File(s) ["+mg_file+"] doesn't exist"
            usage()
            sys.exit(1) 
            
    for fmt in [x for x in fmt_lst if x]:
        if fmt not in supported_formats:
            print "\nWARNING: Output format [",fmt,"] is not supported"
            print "\tUse -h(--help) option for the list of supported formats"
            fmt_lst=["fasta"]
            print "\tUsing default output format: ", fmt_lst[0]
 
    
    project_dir = name
    if os.path.exists(project_dir):
        shutil.rmtree(project_dir)
    try:
        os.mkdir(project_dir)
    except OSError:
        print "ERROR: Cannot create project directory: " + name
        raise
    
    print "\n\t Initial Parameters:"
    print "\nProject Name: ", name,'\n'
    print "Project Directory: ", os.path.abspath(name),'\n'
    print "Reference File(s): ", ref_lst,'\n'
    print "Metagenome File(s): ", mg_lst,'\n'
    print "E Value: ", e_val, "\n"
    print "Alignment Length: ", alen,'\n'
    print "Sequence Identity: ", iden,'\n'
    print "Output Format(s):", fmt_lst,'\n'
    if iterations > 1:
        print "Iterations: ", iterations, '\n'
        print "Alignment Length Increment: ", alen_increment, '\n'
        print "Sequence identity Increment: ", iden_increment, '\n'

    #Initializing directories
    blast_db_Dir = name+"/blast_db"
    if os.path.exists(blast_db_Dir):
        shutil.rmtree(blast_db_Dir)
    try:
        os.mkdir(blast_db_Dir)
    except OSError:
        print "ERROR: Cannot create project directory: " + blast_db_Dir
        raise

    results_Dir = name+"/results"
    if os.path.exists(results_Dir):
        shutil.rmtree(results_Dir)
    try:
        os.mkdir(results_Dir)
    except OSError:
        print "ERROR: Cannot create project directory: " + results_Dir
        raise

    input_files_Dir = name+"/input_files"
    if os.path.exists(input_files_Dir):
        shutil.rmtree(input_files_Dir)
    try:
        os.mkdir(input_files_Dir)
    except OSError:
        print "ERROR: Cannot create project directory: " + input_files_Dir
        raise

# Writing raw reference files into a specific input filename
    input_ref_records = {}
    for reference in ref_lst:
        ref_records_ind = parse_contigs_ind(reference)
        #ref_records = dict(ref_records_ind)
        input_ref_records.update(ref_records_ind)
        ref_records_ind.close()
        #input_ref_records.update(ref_records)
        
    ref_out_0 = input_files_Dir+"/reference0.fna"
    with open(ref_out_0, "w") as handle:
        SeqIO.write(input_ref_records.values(), handle, "fasta")
            #NO NEED TO CLOSE with statement will automatically close the file
        


#    blast_db_Dir = ""
#    results_Dir = ""
#    input_files_Dir = ""
    
#    parsed = SeqIO.parse(handle, "fasta")
#
#    records = list()
#
#
#    total = 0
#    processed = 0
#    for record in parsed:
#        total += 1
#        #print(record.id), len(record.seq)
#        if len(record.seq) >= length:
#            processed += 1
#            records.append(record)
#    handle.close()   
#    
#    print "%d sequences found"%(total)
#    
#    try:
#        output_handle = open(outfile, "w")
#        SeqIO.write(records, output_handle, "fasta")
#        output_handle.close()
#        print "%d sequences written"%(processed)
#    except:
#        print "ERROR: Illegal output filename"
#        sys.exit(1)
    
    
    
if __name__ == "__main__":
    main(sys.argv[1:]) 
