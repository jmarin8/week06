#!/usr/local/bin/perl
use warnings;
use strict;
use DBI;

my $dbfile = "Q5.db";
my $dbh = DBI->connect( "DBI:SQLite:dbname=$dbfile" , "" , "" ,{ PrintError => 0 , RaiseError => 1 });
$dbh->do( "CREATE TABLE IF NOT EXISTS organism (Organism_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  Organism_Name VARCHAR(255) NOT NULL UNIQUE)" );
$dbh->do("CREATE TABLE IF NOT EXISTS tissue (
  Tissue_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  Organism_id INTEGER NOT NULL REFERENCES organism (Organism_id),
  Tissue_name VARCHAR(255) NOT NULL UNIQUE)");
$dbh->do("CREATE TABLE IF NOT EXISTS genes (
  gene_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  tissue_id INTEGER NOT NULL REFERENCES tissue (tissue_id),
  gene_name VARCHAR(255) NOT NULL UNIQUE,
  start_pos INTEGER,
  stop_pos Integer,
  expression_level VARCHAR(255))");
$dbh->do("CREATE TABLE IF NOT EXISTS sequence (
 sequence_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
 gene_id INTEGER NOT NULL REFERENCES genes (gene_id),
 sequence_name Varchar(255) UNIQUE)");
my $filename = 'data.fasta';
if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
  my $gene_id;
  while (my $row = <$fh>) {
    chomp $row;
	my @abc = split(/[>|]/,$row);
	
	if((scalar @abc)>1 ){
		$dbh->do( "INSERT OR IGNORE INTO organism values( null , \"$abc[2]\" )" );
		my $id = $dbh->selectrow_array( "SELECT organism_id FROM organism WHERE organism_name=\"$abc[2]\"" );
		$dbh->do( "INSERT OR IGNORE INTO tissue values( null , $id,\"$abc[3]\")" );
		$id = $dbh->selectrow_array( "SELECT tissue_id FROM tissue WHERE tissue_name=\"$abc[3]\"" );
		$dbh->do( "INSERT OR IGNORE INTO genes values( null , $id,\"$abc[1]\",$abc[4],$abc[5],$abc[6])" );
		$gene_id = $dbh->selectrow_array( "SELECT tissue_id FROM genes WHERE gene_name=\"$abc[1]\"" );
	}
	else{
		if($row =~ /^\s*$/){
			
		}else{
			$dbh->do( "INSERT OR IGNORE INTO sequence values( null , $gene_id,\"$row\")" );
		}
	}

  }
} else {
  warn "Could not open file '$filename' $!";
}
my $count = $dbh->selectrow_array( "SELECT COUNT(*) FROM organism" );
print("No.of rows inserted in organism table: $count\n");
$count = $dbh->selectrow_array( "SELECT COUNT(*) FROM tissue" );
print("No.of rows inserted in tissue table: $count\n");
$count = $dbh->selectrow_array( "SELECT COUNT(*) FROM genes" );
print("No.of rows inserted in genes table: $count\n");
$count = $dbh->selectrow_array( "SELECT COUNT(*) FROM sequence" );
print("No.of rows inserted in sequence table: $count\n");
$dbh->disconnect();
