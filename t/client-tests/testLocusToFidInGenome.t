

use strict;
use warnings;

use Data::Dumper;
use Test::More;



use_ok("Bio::KBase::MOTranslationService::Client");
#my $translation = Bio::KBase::MOTranslationService::Client->new("http://localhost:7061");
my $translation = Bio::KBase::MOTranslationService::Client->new("http://140.221.92.71:7061");
my $target_genome = "kb|g.371";


#################### test 1: get MO data by sql, then call the more general translate method
use DBKernel;

my $dbms='mysql';
my $dbName='genomics';
my $port=3306;
my $user='guest';
my $pass='guest';
my $dbhost='pub.microbesonline.org';
my $sock='';
my $dbKernel = DBKernel->new($dbms, $dbName, $user, $pass, $port, $dbhost, $sock);
my $moDbh=$dbKernel->{_dbh};


my $tax_id = "211586";

my $query_sequences = [];
my $sql='SELECT Locus.locusId,Position.begin,Position.end,AASeq.sequence,Position.strand FROM AASeq,Locus,Scaffold,Position WHERE '.
            'Locus.priority=1 AND Locus.locusId=AASeq.locusId AND Locus.version=AASeq.version AND '.
            'Locus.posId=Position.posId AND Locus.scaffoldId=Scaffold.scaffoldId AND Scaffold.taxonomyId=?';
my $sth=$moDbh->prepare($sql);
$sth->execute($tax_id);
while (my $row=$sth->fetch) {
    # switch the start and stop if we are on the minus strand
    if (${$row}[4] eq '+') {
        push @$query_sequences, {id=>${$row}[0],start=>${$row}[1], stop=>${$row}[2], seq=>${$row}[3] };
    } else {
        push @$query_sequences, {id=>${$row}[0],start=>${$row}[2], stop=>${$row}[1], seq=>${$row}[3] };
    }
}
#print Dumper(@$query_sequences)."\n";

my ($result, $log) = $translation->map_to_fid($query_sequences,$target_genome);
print Dumper($result)."\n";
print "LOG:\n$log\n";










done_testing(1);
