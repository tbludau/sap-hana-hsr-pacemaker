
# https://www.suse.com/documentation/suse-best-practices/singlehtml/SLES4SAP-hana-scaleOut-PerfOpt-12/SLES4SAP-hana-scaleOut-PerfOpt-12.html
# 8.3.4 - 
#´resource create rsc_SAPHanaTop_L01_HDB10 SAPHanaTopology \
#        op monitor interval="10" timeout="600" \
#        op start interval="0" timeout="600" \
#        op stop interval="0" timeout="300" \
#        params SID="L01" InstanceNumber="10"

#resource clone cln_SAPHanaTop_L01_HDB10 rsc_SAPHanaTop_HA1_HDB00 \
#       meta clone-node-max="1" interleave="true"


# 8.3.4 - umgewandelt für pacemaker
pcs resource create rsc_SAPHanaTop_L01_HDB10 SAPHanaTopology InstanceNumber="10"  SID="L01"  op monitor interval="10" timeout="600" op start interval="0" timeout="600" op stop interval="0" timeout="300"

pcs resource clone rsc_SAPHanaTop_L01_HDB10 meta clone-node-max="1" interleave="true"


# 8.3.5
primitive rsc_SAPHanaCon_<SID>_HDB<Inst> ocf:suse:SAPHanaController \
        op start interval="0" timeout="3600" \
        op stop interval="0" timeout="3600" \
        op promote interval="0" timeout="3600" \
        op monitor interval="60" role="Master" timeout="700" \
        op monitor interval="61" role="Slave" timeout="700" \
        params SID="<SID>" InstanceNumber="<Inst>" \
        PREFER_SITE_TAKEOVER="true" \
        DUPLICATE_PRIMARY_TIMEOUT="7200" AUTOMATED_REGISTER="false"

ms msl_SAPHanaCon_<SID>_HDB<Inst> rsc_SAPHanaCon_<SID>_HDB<Inst> \
        meta clone-node-max="1" master-max="1" interleave="true"

# 8.3.5 - umgewandelt für pacemaker
pcs resource create rsc_SAPHanaCon_L01_HDB10 SAPHanaController SID="L01" InstanceNumber="10" \
        PREFER_SITE_TAKEOVER="true" \
        DUPLICATE_PRIMARY_TIMEOUT="7200" AUTOMATED_REGISTER="false" \
        op start interval="0" timeout="3600" \
        op stop interval="0" timeout="3600" \
        op promote interval="0" timeout="3600" \
        op monitor interval="60" role="Master" timeout="700" \
        op monitor interval="61" role="Slave" timeout="700"

# wrong
#pcs resource clone rsc_SAPHanaCon_L01_HDB10 meta clone-node-max="1" master-max="1" interleave="true"

pcs resource master msl_rsc_SAPHana_L01_HDB10 rsc_SAPHanaCon_L01_HDB10 \
  meta clone-node-max=1 interleave=true master-max="1"


# 8.3.6
pcs resource create rsc_ip_L01_HDB10 ocf:heartbeat:IPaddr2 ip=10.97.228.52 op monitor interval="10s" timeout="20s"

# 8.3.7
pcs constraint colocation \
  add rsc_ip_L01_HDB10 with master msl_rsc_SAPHanaCon_L01_HDB10 2000

pcs constraint order \
  rsc_SAPHanaTop_L01_HDB10-clone then msl_rsc_SAPHanaCon_L01_HDB10



colocation col_saphana_ip_HA1_HDB00 2000: rsc_ip_HA1_HDB00:Started \
    msl_SAPHanaCon_HA1_HDB00:Master

order ord_SAPHana_HA1_HDB00 Optional: cln_SAPHanaTop_HA1_HDB00 \
    msl_SAPHanaCon_HA1_HDB00

# 10.2.3
yum install perl-Sys-Syslog-0.33-3.el7.x86_64
mkdir /usr/lib/SAPHanaSR-ScaleOut/
scp -rp ./files/usr/lib/SAPHanaSR-ScaleOut/SAPHanaSRTools.pm  root@tokyohana02:/usr/lib/SAPHanaSR-ScaleOut/SAPHanaSRTools.pm
