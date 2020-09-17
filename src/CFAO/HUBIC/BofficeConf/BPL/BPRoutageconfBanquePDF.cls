/// 
Class CFAO.HUBIC.BofficeConf.BPL.BPRoutageconfBanquePDF Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2800' width='6470' >
<context>
<property name='%Process' type='Ens.BusinessProcess' instantiate='0' />
<property name='contextRequest' type='%Library.String' instantiate='0' />
<property name='Reason' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20000' />
</parameters>
</property>
<property name='MailErreurTexte' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20000' />
</parameters>
</property>
<property name='result' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='resultUserDesc' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
<property name='NomFichier' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
<property name='NomConfTXTenTraitement' type='Ens.StringRequest' instantiate='0' />
<property name='contextReport' type='CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf' instantiate='0' />
<property name='StatutPDFtoTXT' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
</context>
<sequence xend='200' yend='1200' >
<code name='Routage Fichier' xpos='200' ypos='250' >
<![CDATA[ 
 
 Set context.NomConfTXTenTraitement = ##class(Ens.StringRequest).%New() 
 set context.NomConfTXTenTraitement.StringValue = $Piece(request.OriginalFilename,"\",$LENGTH(request.OriginalFilename,"\"))
 //$$$LOGINFO("NomConfTXTenTraitement : " _ context.NomConfTXTenTraitement.StringValue)
   ]]>
</code>
<assign property="context.NomFichier" value="context.NomConfTXTenTraitement.StringValue" action="set" xpos='200' ypos='350' />
<call name='Transform PDF to TXT' target='Transform BO Conf Banques PDF to TXT' async='0' xpos='200' ypos='450' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.resultUserDesc" value="callresponse.StringValue" action="set" />
</response>
</call>
<if condition='context.resultUserDesc = "OK"' xpos='200' ypos='550' xend='200' yend='1100' >
<true>
<call name='Depot PDF renommé' target='Depot BO Conf Banques PDF to TXT' async='0' xpos='200' ypos='700' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' />
</call>
<code name='Routage Fichier' xpos='200' ypos='800' >
<![CDATA[ //$$$LOGINFO("NomConfTXTenTraitement 2: " _ context.NomConfTXTenTraitement.StringValue)
   ]]>
</code>
<transform name='Report OK' class='CFAO.HUBIC.BofficeConf.Report.PDFtoTXT.DataTransform.ReportOK' source='context.NomConfTXTenTraitement' target='context.contextReport' xpos='200' ypos='900' />
</true>
<false>
<code name='Construction Mail Erreur' xpos='470' ypos='700' >
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3) 
 
  
 
 //Construction du mail d'erreur
  Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"l'EAI a détécté une Erreur pour une confirmation de la banque : "_request.OriginalFilename_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Description de l'erreur : "_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_context.resultUserDesc_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_$c(13,10)_$c(13,10)_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
]]>
</code>
<call name='Enregistrement erreur' target='Enregistrement Erreurs CFAO' async='0' xpos='470' ypos='800' >
<request type='CFAO.HUBIC.Alertes.AlertMsg' >
<assign property="callrequest.MailErreurTexte" value="context.MailErreurTexte" action="set" />
<assign property="callrequest.Reason" value="context.Reason" action="set" />
<assign property="callrequest.ResultNomFichier" value="context.NomFichier" action="set" />
<assign property="callrequest.SourceConfigName" value="context.%Process.%ConfigName" action="set" />
<assign property="callrequest.ErrorType" value="&quot;2&quot;" action="set" />
<assign property="callrequest.ResultUserDesc" value="context.resultUserDesc" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert value='context.MailErreurTexte' xpos='470' ypos='900' />
<transform name='Report ERR' class='CFAO.HUBIC.BofficeConf.Report.PDFtoTXT.DataTransform.ReportERR' source='context.NomConfTXTenTraitement' target='context.contextReport' xpos='470' ypos='1000' />
</false>
</if>
</sequence>
</process>
}

}
