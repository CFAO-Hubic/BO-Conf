/// 
Class CFAO.HUBIC.BofficeConf.BPL.RoutageEmailbanques Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2050' width='2000' >
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
<property name='%Process' type='Ens.BusinessProcess' instantiate='0' />
<property name='SatutDepotFichier' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2000' />
</parameters>
</property>
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
<property name='contextReport' type='CFAO.HUBIC.EMIRtools.Report.Table.ReportEMIR' instantiate='0' />
<property name='NomFichier' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20000' />
</parameters>
</property>
<property name='StatutPdtToTxt' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='5000' />
</parameters>
</property>
<property name='NomFichierConfbanques' type='Ens.StringRequest' instantiate='0' />
<property name='StatutRecupconfMail' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='10' />
</parameters>
</property>
<property name='NomFileConfMail' type='Ens.StringRequest' instantiate='0' />
</context>
<sequence xend='200' yend='1750' >
<code xpos='200' ypos='250' >
<![CDATA[ //$$$LOGINFO("debut traitement")
  
]]>
</code>
<assign property="context.NomFichier" value="request.Read()" action="set" xpos='200' ypos='350' />
<code xpos='200' ypos='450' >
<![CDATA[ //$$$LOGINFO("context.NomFichier : "_context.NomFichier)]]>
</code>
<call name='Dépot File EAI' target='Depot BO Conf Email Banques' async='0' xpos='200' ypos='550' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutPdtToTxt" value="callresponse.StringValue" action="set" />
</response>
</call>
<code name='Satut recup Conf mail' xpos='200' ypos='650' >
<![CDATA[ //$$$LOGINFO("context.StatutPdtToTxt:"_context.StatutPdtToTxt)
 
 // On recupere le statut du BO
 Set context.StatutRecupconfMail = $Piece(context.StatutPdtToTxt,"!##!",1)
 //$$$LOGINFO("context.StatutRecupconfMail :"_context.StatutRecupconfMail)
 
 //On recupere le nom du fichier en sortie du BO
 Set context.NomFileConfMail = ##class(Ens.StringRequest).%New()
 set context.NomFileConfMail.StringValue = $Piece(context.StatutPdtToTxt,"!##!",2)
 //$$$LOGINFO("context.NomFileConfMail.StringValue : "_context.NomFileConfMail.StringValue)
 
 ]]>
</code>
<if name='Recup Info Mail OK' condition='context.StatutRecupconfMail &apos;= "ERROR"' xpos='200' ypos='750' xend='200' yend='1300' >
<true>
<code xpos='200' ypos='900' >
<![CDATA[ Set context.NomFileConfMail.StringValue = $Replace(context.NomFileConfMail.StringValue ,"!@@!","-")
 //$$$LOGINFO("context.NomFileConfMail.StringValueOK : "_context.NomFileConfMail.StringValue)]]>
</code>
<transform name='Alim Report OK' class='CFAO.HUBIC.BofficeConf.Report.EmailPJ.DataTransform.ReportOK' source='context.NomFileConfMail' target='context.contextReport' xpos='200' ypos='1000' />
<code xpos='200' ypos='1100' disabled="true">
<![CDATA[ $$$LOGINFO("Paasage OK")]]>
</code>
</true>
<false>
<transform name='Alim Report Error' class='CFAO.HUBIC.BofficeConf.Report.EmailPJ.DataTransform.ReportERR' source='context.NomFileConfMail' target='context.contextReport' xpos='470' ypos='900' />
<code name='Construction Mail Erreur' xpos='470' ypos='1000' >
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3)
 
 //set context.resultNomFichier = context.NomFichier
 Set context.resultUserDesc = "Erreur Récuperation du mail de confirmation"
 if $Find(context.NomFileConfMail.StringValue,"!@@!") > 0{
    Set FirstFileInError = $Piece(context.NomFileConfMail.StringValue,"!@@!",1)
 }else{
    Set FirstFileInError = $Replace(context.NomFileConfMail.StringValue,"!@@!","-")
 }
 
 
 
 Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Erreur de récuperation de la piece jointe de confirmation : "_context.NomFileConfMail.StringValue_$c(13,10)_$c(13,10)
 //Set context.MailErreurTexte = FirstFileInError_"Description de l'erreur : La confirmation"_context.resultUserDesc_$c(13,10)_$c(13,10) 
 Set context.MailErreurTexte = context.MailErreurTexte_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
 
 //$$$LOGINFO("AV context.MailErreurTexte")
 //$$$LOGINFO("context.MailErreurTexte:"_context.MailErreurTexte)
 //$$$LOGINFO("AP context.MailErreurTexte")
 Set context.NomFichier = FirstFileInError
 Set context.MailErreurTexte = $Replace(context.MailErreurTexte,"!@@!","-")]]>
</code>
<call name='Enregistrement erreur' target='Enregistrement Erreurs CFAO' async='0' xpos='470' ypos='1100' >
<request type='CFAO.HUBIC.Alertes.AlertMsg' >
<assign property="callrequest.MailErreurTexte" value="context.MailErreurTexte" action="set" />
<assign property="callrequest.Reason" value="context.reason" action="set" />
<assign property="callrequest.ResultNomFichier" value="context.NomFichier" action="set" />
<assign property="callrequest.SourceConfigName" value="context.%Process.%ConfigName" action="set" />
<assign property="callrequest.ErrorType" value="&quot;2&quot;" action="set" />
<assign property="callrequest.ResultUserDesc" value="context.resultUserDesc" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert name='Fatal Error' value='context.MailErreurTexte' xpos='470' ypos='1200' />
</false>
</if>
<if name='Si Conf CACIB' condition='context.NomFichier = "Confirmation.pdf"' xpos='200' ypos='1400' xend='200' yend='1650' >
<true>
<code xpos='335' ypos='1550' >
<![CDATA[ HANG 20]]>
</code>
</true>
</if>
</sequence>
</process>
}

}
