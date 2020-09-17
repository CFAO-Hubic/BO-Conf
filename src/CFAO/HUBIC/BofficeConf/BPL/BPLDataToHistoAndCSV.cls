/// 
Class CFAO.HUBIC.BofficeConf.BPL.BPLDataToHistoAndCSV Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2750' width='2000' >
<context>
<property name='result' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='reason' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20000' />
</parameters>
</property>
<property name='contextRequest' type='CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV' instantiate='0' />
<property name='MailErreurTexte' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20000' />
</parameters>
</property>
<property name='resultUserDesc' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
<property name='NomFichier' type='Ens.StringRequest' instantiate='0' />
<property name='ReportGlobal' type='CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf' instantiate='0' />
<property name='StautBoDepotCSV' type='%Integer' instantiate='0' />
<property name='NomFileCSV' type='Ens.StringRequest' instantiate='0' />
</context>
<sequence xend='200' yend='1000' >
<assign name="Initialisation du context" property="context.contextRequest" value="request" action="set" xpos='200' ypos='250' />
<code xpos='200' ypos='350' >
<![CDATA[ //$$$LOGINFO("request.Filename : "_request.%Source)
 
 //On recupere le nom du fichier en sortie du BO
 Set context.NomFileCSV = ##class(Ens.StringRequest).%New()
 set context.NomFileCSV.StringValue = request.%Source
 ]]>
</code>
<call name='Reporting EMIR' target='Depot BO Conf Match CSV' async='0' xpos='200' ypos='450' >
<request type='CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV' >
<assign property="callrequest" value="context.contextRequest" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StautBoDepotCSV" value="callresponse.StringValue" action="set" />
</response>
</call>
<switch name='Result BO ?' xpos='200' ypos='550' xend='200' yend='900' >
<case condition='context.StautBoDepotCSV = 1' name='Mail Error' >
<code xpos='335' ypos='700' disabled="true">
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3) 
 
 
 
 
 Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Erreur d'envoi par mail du fichier FOREX FINANCE : "_StatutBoForexNomDuFichier_$c(13,10)_$c(13,10)
 //Set context.MailErreurTexte = FirstFileInError_"La Trade Date en erreur est : "_StatutBoForexTradeDate  _$c(13,10)_$c(13,10) 
 Set context.MailErreurTexte = context.MailErreurTexte_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
 

 $$$LOGINFO("context.MailErreurTexte:"_context.MailErreurTexte)
]]>
</code>
<transform name='Report Global Forex ERR' class='CFAO.HUBIC.BofficeConf.Report.CSVrepot.DataTransform.ReportERR' source='context.NomFileCSV' target='context.ReportGlobal' xpos='335' ypos='800' />
</case>
<case condition='context.StautBoDepotCSV = 0' name='OK' >
<transform name='Pour Diapason UTI' class='CFAO.HUBIC.EMIRtools.DtTransform.DiapasonFileUpdateUTI' source='context.contextRequest' target='context.DiapasonUTIupdate' xpos='605' ypos='700' disabled="true"/>
<transform name='Report Global Forex OK' class='CFAO.HUBIC.BofficeConf.Report.CSVrepot.DataTransform.ReportOK' source='context.NomFileCSV' target='context.ReportGlobal' xpos='605' ypos='800' />
</case>
<default/>
</switch>
</sequence>
</process>
}

}
