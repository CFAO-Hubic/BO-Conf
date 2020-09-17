/// 
Class CFAO.HUBIC.BofficeConf.BPL.RoutageJrnForex Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2100' width='2000' >
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
<parameter name='MAXLEN'  value='20000' />
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
<property name='contextReport' type='CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf' instantiate='0' />
<property name='NomFichier' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2000' />
</parameters>
</property>
<property name='contextJrnForex' type='CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch' instantiate='0' />
<property name='contextValidEmirTab' type='CFAO.HUBIC.BofficeConf.Table.JrnForexTab' instantiate='0' />
<property name='NomFileJrnForex' type='Ens.StringRequest' instantiate='0' />
<property name='errors' type='%Library.DynamicArray' instantiate='0' />
</context>
<sequence xend='200' yend='1850' >
<assign property="context.contextJrnForex" value="request" action="set" xpos='200' ypos='250' />
<code name='Instanciation Global d&apos;erreur' xpos='200' ypos='350' >
<annotation><![CDATA[Set ^zBoConfVerifDoublonsInFile = ""
 Set ^zBoConfVerifDejalisteRappro= ""
 Set ^zBoConfVerifDejaTraiter = ""]]></annotation>
<![CDATA[ Set ^zBoConfVerifDoublonsInFile = ""
 Set ^zBoConfVerifDejalisteRappro= ""
 Set ^zBoConfVerifDejaTraiter = ""
 ]]>
</code>
<rule name='Verification de Validation' rule='CFAO.HUBIC.BofficeConf.Rules.BRulesBoConf'  resultLocation='context.result' reasonLocation='context.reason' ruleContext='context' xpos='200' ypos='450' >
</rule>
<code xpos='200' ypos='550' >
<![CDATA[ //$$$LOGINFO("context.result: "_context.result)
 
 //On recupere le nom du fichier en sortie du BO
 Set context.NomFileJrnForex = ##class(Ens.StringRequest).%New()
 set context.NomFileJrnForex.StringValue = request.%Source]]>
</code>
<if name='If all validated' condition='context.result=0' xpos='200' ypos='650' xend='200' yend='1750' >
<true>
<transform name='Jrn Forex To EAI' class='CFAO.HUBIC.BofficeConf.DT.forexToEAI' source='context.contextJrnForex' target='context.contextValidEmirTab' xpos='470' ypos='800' />
<call name='Conf Banques Existe ?' target='Enreg BO Conf Journal Forex' async='0' xpos='470' ypos='900' >
<request type='CFAO.HUBIC.BofficeConf.tables.forexBatch' >
<assign property="callrequest" value="context.contextValidEmirTab" action="set" />
</request>
<response type='CFAO.HUBIC.BofficeConf.messages.checkForexMsg' >
<assign property="context.errors" value="callresponse" action="set" />
</response>
</call>
<code name='Result ?' xpos='470' ypos='1000' disabled="true">
<![CDATA[ Set context.StatutBoRapproConf = $Piece(context.SatutDepotFichier,"!##!",1)
 //$$$LOGINFO("context.StatutBoRapproConf : "_context.StatutBoRapproConf )
 /*
 if context.StatutBoRapproConf = 1 {
    Set BanqueTraiter = $Piece(context.SatutDepotFichier,"!##!",2)
    Set EnregRapproJrnForexErr = $Piece(context.SatutDepotFichier,"!##!",3)        
    Set EnregRapproConfBanqueErr = $Piece(context.SatutDepotFichier,"!##!",4)
 }*/
 ]]>
</code>
<if name='OK' condition='context.errors.status = 0' xpos='470' ypos='1100' xend='470' yend='1650' >
<true>
<transform name='Report OK' class='CFAO.HUBIC.BofficeConf.Report.JrnForex.DataTransform.ReportOK' source='context.NomFileJrnForex' target='context.contextReport' xpos='470' ypos='1250' />
</true>
<false>
<code name='Construction Mail Warning' xpos='740' ypos='1250' >
<![CDATA[ set context.resultUserDesc = "Erreur de Rappochement"
 set forex = context.errors.forex
 set bank = context.errors.bank
 
 if forex.%Size {
 	 set forexMsg = "Erreur de mise a jour du rapprochement des lignes du journal Forex suivantes : "_$c(13,10)
 	 
 	 set iter = forex.%GetIterator()
	 while iter.%GetNext(.key , .val) {
		 set separator = ""
		 if forex.%Size() = key - 1 set separator = ", "
		 set forexMsg = forexMsg _ val _ separator
	 }
 }
 
 if bank.%Size {
 	 set forexMsg = "Erreur de mise a jour du rapprochement des lignes de banque suivantes : "_$c(13,10)
 	 
 	 set iter = bank.%GetIterator()
	 while iter.%GetNext(.key , .val) {
		 set separator = ""
		 if bank.%Size() = key - 1 set separator = ", "
		 set bankMsg = bankMsg _ val _ separator
	 }
 }
 
 set context.MailErreurTexte =
 	 "Bonjour,"_$c(13,10)_$c(13,10)
 	_"Nous sommes le "_$ZDATE($h, 4)_$c(13,10)
 	_"Un Warning a été detectée lors de rapprochement pour le fichier : "_request.%Source_$c(13,10)_$c(13,10)
 	_"Description de l'erreur :"_$c(13,10)_$c(13,10)
 	_forexMsg
 	_bankMsg
	_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"]]>
</code>
<call name='Enregistrement Warning' target='Enregistrement Erreurs CFAO' async='0' xpos='740' ypos='1350' >
<request type='CFAO.HUBIC.Alertes.AlertMsg' >
<assign property="callrequest.MailErreurTexte" value="context.MailErreurTexte" action="set" />
<assign property="callrequest.Reason" value="context.reason" action="set" />
<assign property="callrequest.ResultNomFichier" value="request.%Source" action="set" />
<assign property="callrequest.ResultUserDesc" value="context.resultUserDesc" action="set" />
<assign property="callrequest.SourceConfigName" value="context.%Process.%ConfigName" action="set" />
<assign property="callrequest.ErrorType" value="&quot;1&quot;" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert value='context.MailErreurTexte' xpos='740' ypos='1450' />
<transform name='Report WAR' class='CFAO.HUBIC.BofficeConf.Report.JrnForex.DataTransform.ReportWAR' source='request.%Source' target='context.contextReport' xpos='740' ypos='1550' />
</false>
</if>
</true>
<false>
<code name='Construction Mail Erreur' xpos='200' ypos='800' >
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3)
 
 //set context.resultNomFichier = request.%Source
 Set EmirToolsVerifDoublonsInFile = ^zBoConfVerifDoublonsInFile 
 Set EmirToolsVerifDejalisteRappro= ^zBoConfVerifDejalisteRappro
 Set EmirToolsVerifDejaTraiter = ^zBoConfVerifDejaTraiter
 
 Kill ^zBoConfVerifDoublonsInFile
 Kill ^zBoConfVerifDejalisteRappro
 Kill ^zBoConfVerifDejaTraiter
 
 
 Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Une Erreur a été detectée par l'EAI sur la structure du fichier : "_request.%Source_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Description de l'erreur : "_context.resultUserDesc_$c(13,10)_$c(13,10) 
 If EmirToolsVerifDoublonsInFile '= "" {
    Set context.MailErreurTexte = context.MailErreurTexte_"Liste des Id Forex En doublons : "_EmirToolsVerifDoublonsInFile_$c(13,10)_$c(13,10)
 }
 If EmirToolsVerifDejalisteRappro '= "" {
    Set context.MailErreurTexte = context.MailErreurTexte_"Liste des Id Forex déjà envoyés : "_EmirToolsVerifDejalisteRappro_$c(13,10)_$c(13,10)
 }
 If EmirToolsVerifDejaTraiter '= "" {
    Set context.MailErreurTexte = context.MailErreurTexte_"Liste des Id Forex déjà envoyés : "_EmirToolsVerifDejaTraiter_$c(13,10)_$c(13,10)
 }
 Set context.MailErreurTexte = context.MailErreurTexte_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
 
 
 //On ajoute les IdForex manquant a resultatdesc 
 If EmirToolsVerifDoublonsInFile '= "" {
    Set context.resultUserDesc = context.resultUserDesc _": "_EmirToolsVerifDoublonsInFile_$c(13,10)
 }
 If EmirToolsVerifDejalisteRappro '= "" {
    Set context.resultUserDesc = context.resultUserDesc _": "_EmirToolsVerifDejalisteRappro_$c(13,10)
 }
 If EmirToolsVerifDejaTraiter '= "" {
    Set context.resultUserDesc = context.resultUserDesc _": "_EmirToolsVerifDejaTraiter _$c(13,10)
 }
 
 //$$$LOGINFO("context.MailErreurTexte : "_context.MailErreurTexte)]]>
</code>
<call name='Enregistrement erreur' target='Enregistrement Erreurs CFAO' async='0' xpos='200' ypos='900' >
<request type='CFAO.HUBIC.Alertes.AlertMsg' >
<assign property="callrequest.MailErreurTexte" value="context.MailErreurTexte" action="set" />
<assign property="callrequest.Reason" value="context.reason" action="set" />
<assign property="callrequest.ResultNomFichier" value="request.%Source" action="set" />
<assign property="callrequest.ResultUserDesc" value="context.resultUserDesc" action="set" />
<assign property="callrequest.SourceConfigName" value="context.%Process.%ConfigName" action="set" />
<assign property="callrequest.ErrorType" value="&quot;2&quot;" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert value='context.MailErreurTexte' xpos='200' ypos='1000' />
<transform name='Report ERR' class='CFAO.HUBIC.BofficeConf.Report.JrnForex.DataTransform.ReportERR' source='context.NomFileJrnForex' target='context.contextReport' xpos='200' ypos='1100' />
</false>
</if>
</sequence>
</process>
}

}
