pcs property set maintenance-mode=true
pcs resource create rsc_SAPHanaTopology_L01_HDB10 SAPHanaTopology \
  SID=L01 \
  InstanceNumber=10 \
  op start timeout=600 \
  op stop timeout=300 \
  op monitor interval=10 timeout=600

pcs resource clone rsc_SAPHanaTopology_L01_HDB10 meta clone-node-max=1 interleave=true

pcs resource create rsc_SAPHana_L01_HDB10 SAPHanaController \
  SID=L01 \
  InstanceNumber=10 \
  PREFER_SITE_TAKEOVER=true \
  DUPLICATE_PRIMARY_TIMEOUT=7200 \
  AUTOMATED_REGISTER=true \
  op start interval=0 timeout=3600 \
  op stop interval=0 timeout=3600 \
  op promote interval=0 timeout=3600 \
  op monitor interval=60 role="Master" timeout=700 \
  op monitor interval=61 role="Slave" timeout=700

pcs resource master msl_rsc_SAPHana_L01_HDB10 rsc_SAPHana_L01_HDB10 \
  meta master-max="1" clone-node-max=1 interleave=true

pcs resource create rsc_ip_SAPHana_L01_HDB10 ocf:heartbeat:IPaddr2 ip=10.97.228.52 op monitor interval="10s" timeout="20s"

pcs constraint colocation \
  add rsc_ip_SAPHana_L01_HDB10 with master msl_rsc_SAPHana_L01_HDB10

pcs constraint order \
  rsc_SAPHanaTopology_L01_HDB10-clone then msl_rsc_SAPHana_L01_HDB10 

pcs constraint location msl_rsc_SAPHana_L01_HDB10 avoids majorityhana01
pcs constraint location rsc_SAPHanaTopology_L01_HDB10-clone avoids majorityhana01

pcs property set maintenance-mode=false
#  172  psc resource delete rsc_SAPHanaTopology_L01_HDB10
#  173  pcs resource delete rsc_SAPHanaTopology_L01_HDB10
#  174  pcs resource delete rsc_SAPHana_L01_HDB10
#  175  pcs resource delete msl_rsc_SAPHana_L01_HDB10
#  176  pcs resrouce delete rsc_ip_L01_HDB10
#  177  pcs resource delete rsc_ip_L01_HDB10

