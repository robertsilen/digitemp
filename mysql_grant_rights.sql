##########################################################################
# $Id: mysql_grant_rights.sql,v 1.1 2005-11-03 12:01:32 ak Exp $
##########################################################################
#
# Sql script to grant rights for user digitemp on database digitemp.
#
##########################################################################
# $Log: mysql_grant_rights.sql,v $
# Revision 1.1  2005-11-03 12:01:32  ak
# README & other usage information written
#
##########################################################################
GRANT SELECT,INSERT ON digitemp.* TO digitemp@localhost
IDENTIFIED BY 'DiGiTeMp';
