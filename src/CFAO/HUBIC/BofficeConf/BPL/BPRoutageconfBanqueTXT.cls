/// 
Class CFAO.HUBIC.BofficeConf.BPL.BPRoutageconfBanqueTXT Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2800' width='7010' >
<context>
<property name='%Process' type='Ens.BusinessProcess' instantiate='0' />
<property name='bank' type='%String' initialexpression='""' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='contextRequest' type='%Library.String' instantiate='0' />
<property name='StatutEnregInfo' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
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
<property name='ConfirmationAtraiter' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='3' />
</parameters>
</property>
<property name='EmetteurConfirmation' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='8' />
</parameters>
</property>
<property name='isSpot' type='%Boolean' initialexpression='0' instantiate='0' />
<property name='typeConf' type='%String' initialexpression='""' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='20' />
</parameters>
</property>
<property name='ComptantTrouver' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='3' />
</parameters>
</property>
<property name='tSC' type='CFAO.HUBIC.BofficeConf.messages.checkBankMsg' instantiate='0' />
</context>
<sequence xend='200' yend='1900' >
<code name='Identification banque' xpos='200' ypos='250' >
<![CDATA[ While 'request.AtEnd {    
	Set line = request.ReadLine()

	if $FIND(line,"NATIXIS") set context.bank = "NAT"
	if $FIND(line,"CA-CIB") set context.bank = "CACIB"
	if $FIND(line,"SOCIETE GENERALE") set context.bank = "SG"
	if $FIND(line,"Barclays") set context.bank = "BAR"
	if $FIND(line,"BNP PARIBAS") set context.bank = "BNP"
 }]]>
</code>
<switch name='Routage banque' xpos='200' ypos='350' xend='200' yend='950' >
<case condition='context.bank = ""' name='Défaut' >
<code name='Banque non identifiée' xpos='200' ypos='500' >
<![CDATA[ set context.tSC = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
 set context.tCS.status = 999
 set context.tCS.message = "Echec de l'identification de la banque. Pas de traitement."]]>
</code>
</case>
<case condition='context.BanqueTraitée = "CACIB"' name='CA-CIB' >
<code name='Identification type de conf' xpos='470' ypos='500' >
<![CDATA[ set found = 0
 
 while 'request.AtEnd && 'found {
	set line = request.ReadLine()

	if $FIND(line ,"UNE OPERATION DE CHANGE A TERME") set context.typeConf = "MEP TERME", found = 1
	if $FIND(line ,"UNE OPERATION DE CHANGE AU COMPTANT") set context.typeConf = "MEP SPOT", found = 1
	if $FIND(line ,"UNE OPÉRATION DE SWAP DE CHANGE") set context.typeConf= "SWAP", found = 1
	if $FIND(line ,"LEVÉE") set context.typeConf = "LEVEE", found = 1
	if $FIND(line ,"REPORT") set context.typeConf= "PRORO", found = 1
 }]]>
</code>
<switch name='Routage conf' xpos='470' ypos='600' xend='470' yend='850' >
<case condition='context.typeConf = "LEVEE"' name='LEVEE' >
<call name='Enreg Conf CACIB LEVEE' target='Enreg BO Conf CACIB LEVEE' async='0' xpos='470' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "MEP TERME"' name='MEP TERME' >
<call name='Enreg CACIB MEP Terme' target='Enreg BO Conf CACIB MEP Terme' async='0' xpos='740' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "PRORO"' name='PRORO' >
<call name='Enreg Conf CACIB PRORO' target='Enreg BO Conf CACIB PRORO' async='0' xpos='1010' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "SWAP"' name='SWAP' >
<call name='Enreg CACIB MEP SWAP' target='Enreg BO Conf CACIB SWAP' async='0' xpos='1280' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "MEP SPOT"' name='MEP SPOT' >
<call name='Enreg CACIB MEP Comptant' target='Enreg BO Conf CACIB MEP Comptant' async='0' xpos='1550' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = ""' name='Défaut' >
<code name='Type conf non identifié' xpos='1820' ypos='750' >
<![CDATA[ set context.tSC = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
 set context.tCS.status = 999
 set context.tCS.message = "Echec de l'identification du type de confirmation. Pas de traitement."]]>
</code>
</case>
</switch>
</case>
<case condition='context.BanqueTraitée = "BNP"' name='BNP' >
<code name='Identification type de conf' xpos='2090' ypos='500' >
<![CDATA[ set found = 0

 while 'request.AtEnd && 'found {
	set line = request.ReadLine()

	if $Find(line ,"UNE OPERATION DE CHANGE") set context.typeConf = "MEP", found = 1
	if $Find(line ,"SWAP") set context.typeConf= "FXSWAP", found = 1
 }]]>
</code>
<switch name='Routage conf' xpos='2090' ypos='600' xend='2090' yend='850' >
<case condition='context.TypeConfirmation= "MEP"' name='MEP' >
<call name='Enreg Conf BNP MEP' target='Enreg BO Conf BNP MEP' async='0' xpos='2090' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "FXSWAP"' name='FX SWAP' >
<call name='Enreg Conf BNP FXSWAP' target='Enreg BO Conf BNP FXSWAP' async='0' xpos='2360' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "SPOT"' name='SPOT' >
<call name='Enreg Conf BNP SPOT' target='Enreg BO Conf BNP SPOT' async='0' xpos='2630' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = ""' name='défault' >
<code name='Type conf non identifié' xpos='2900' ypos='750' >
<![CDATA[ set context.tSC = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
 set context.tCS.status = 999
 set context.tCS.message = "Echec de l'identification du type de confirmation. Pas de traitement."]]>
</code>
</case>
</switch>
</case>
<case condition='context.BanqueTraitée = "SG"' name='Societe Generale' >
<code name='Identification type de conf' xpos='3170' ypos='500' >
<![CDATA[ set found = 0
 set isSpot = 0

 While 'request.AtEnd { 
	set line = request.ReadLine()

	//Recherche la présence du terme SPOT, auquel cas il s'agit d'une MEP à ne pas traiter
	if $FIND(line ,"SPOT") set isSpot = 1

	if 'found && $FIND(line ,"Prorogation des Opérations") set context.typeConf= "PRORO", found = 1
	if 'found && $FIND(line ,"Levée") set context.typeConf= "LEVEE", found = 1
	if 'found && $FIND(line ,"SWAP") set context.typeConf= "SWAP", found = 1
 }

 if 'found && 'isSpot set context.typeConf= "MEP TERME"
 if 'found && isSpot set context.typeConf= "MEP SPOT"]]>
</code>
<switch name='Routage conf' xpos='3170' ypos='600' xend='3170' yend='850' >
<case condition='context.TypeConfirmation= "PRORO"' name='PRORO' >
<call name='Enreg Conf SG PRORO' target='Enreg BO Conf SG PRORO' async='0' xpos='3170' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "LEVEE"' name='LEVEE' >
<call name='Enreg Conf SG LEVEE' target='Enreg BO Conf SG LEVEE' async='0' xpos='3440' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "SWAP"' name='SWAP' >
<call name='Enreg SG SWAP' target='Enreg BO Conf SG SWAP' async='0' xpos='3710' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "MEP SPOT"' name='MEP SPOT' >
<call name='Enreg SG MEP Comptant' target='Enreg BO Conf SG MEP Comptant' async='0' xpos='3980' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = "MEP TERME"' name='MEP TERME' >
<call name='Enreg SG MEP Terme' target='Enreg BO Conf SG MEP Terme' async='0' xpos='4250' ypos='750' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = ""' name='Défaut' >
<code name='Type conf non identifié' xpos='4520' ypos='750' >
<![CDATA[ set context.tSC = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
 set context.tCS.status = 999
 set context.tCS.message = "Echec de l'identification du type de confirmation. Pas de traitement."]]>
</code>
</case>
</switch>
</case>
<case condition='context.BanqueTraitée = "NAT"' name='NATIXIS' >
<code name='Identification type de conf' xpos='4790' ypos='500' >
<![CDATA[ set found = 0
 set isSpot = 0

 While 'request.AtEnd { 
	set line = request.ReadLine()

	//Recherche la présence du terme SPOT, auquel cas il s'agit d'une MEP à ne pas traiter
	if $FIND(line ,"SPOT") set isSpot = 1

	if 'found && $FIND(line ,"Levée") set context.typeConf = "LEVEE", found = 1
	if 'found && $FIND(line ,"Proro") set context.typeConf = "SWAP", found = 1
 }

 if 'found && 'isSpot set context.typeConf = "MEP TERME"
 if 'found && isSpot set context.typeConf = "MEP SPOT"
 if context.typeConf = "PRORO" && 'isSpot set context.typeConf = "PRORO TERME"
 if context.typeConf = "PRORO" && isSpot set context.typeConf = "PRORO SPOT"]]>
</code>
<switch name='Routage conf' xpos='4790' ypos='600' xend='4790' yend='850' >
<case condition='context.TypeConfirmation= "LEVEE"' name='LEVEE' >
<call name='Enreg Conf NAT Levée' target='Enreg BO Conf NATIXIS LEVEE' async='0' xpos='4790' ypos='750' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "PRORO SPOT"' name='PRORO SPOT' >
<call name='Enreg NAT Proro Comptant' target='Enreg BO Conf NATIXIS PRORO Comptant' async='0' xpos='5060' ypos='750' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "PRORO TERME"' name='PRORO TERME' >
<call name='Enreg NAT Proro Terme' target='Enreg BO Conf NATIXIS PRORO Terme' async='0' xpos='5330' ypos='750' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "MEP SPOT"' name='MEP SPOT' >
<call name='Enreg NAT MEP Comptant' target='Enreg BO Conf NATIXIS MEP Comptant' async='0' xpos='5600' ypos='750' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.TypeConfirmation= "MEP TERME"' name='MEP TERME' >
<call name='Enreg NAT MEP Terme' target='Enreg BO Conf NATIXIS MEP Terme' async='0' xpos='5870' ypos='750' >
<request type='Ens.StreamContainer' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.StringResponse' >
<assign property="context.StatutEnregInfo" value="callresponse.StringValue" action="set" />
</response>
</call>
</case>
<case condition='context.typeConf = ""' name='Défaut' >
<code name='Type conf non identifié' xpos='6140' ypos='750' >
<![CDATA[ set context.tSC = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
 set context.tCS.status = 999
 set context.tCS.message = "Echec de l'identification du type de confirmation. Pas de traitement."]]>
</code>
</case>
</switch>
</case>
</switch>
<code name='Statut OK / PAS OK' xpos='200' ypos='1050' >
<![CDATA[ Set StatutERR = $Piece(context.StatutEnregInfo,"!##!",1)
 Set StatutBanque = $Piece(context.StatutEnregInfo,"!##!",2)
 Set StatutDescritionERR = $Piece(context.StatutEnregInfo,"!##!",3)
 //$$$LOGINFO("Fichier traité : "_context.NomConfTXTenTraitement.StringValue)
 
 set context.NomConfTXTenTraitement.StringValue = context.NomConfTXTenTraitement.StringValue_"!##!"_context.BanqueTraitée _ "!##!" _ context.TypeConfirmation
 //$$$LOGINFO("Fichier traité : "_context.NomConfTXTenTraitement.StringValue)]]>
</code>
<switch name='Routage Erreur' xpos='200' ypos='1150' xend='200' yend='1800' >
<case condition='context.tSC.status = 999' name='Conf Non Traitée' >
<code xpos='335' ypos='1300' >
<![CDATA[ //$$$LOGINFO("Passage 999")
  //Formatage du nom du fichier
 Set context.NomFichier= $Piece(context.NomFichier,"\",$Length(context.NomFichier,"\")) 

 //$$$LOGINFO("Fichier : "_context.NomFichier_" ==> "_context.StatutEnregInfo)
]]>
</code>
</case>
<case condition='context.tSC.status = 0' name='OK' >
<code xpos='605' ypos='1300' disabled="true">
<![CDATA[ $$$LOGINFO("PASSAGE OK")
 
 //set context.NomConfTXTenTraitement.StringValue = context.NomConfTXTenTraitement.StringValue_"!##!Conf"_context.BanqueTraitée ]]>
</code>
<transform name='Report OK' class='CFAO.HUBIC.BofficeConf.Report.ConfBanqueTxt.DataTransform.ReportOK' source='context.NomConfTXTenTraitement' target='context.contextReport' xpos='605' ypos='1400' />
</case>
<case condition='context.tSC.status = 2' name='Warning' >
<code xpos='875' ypos='1300' disabled="true"/>
<code name='Construction Mail Warning' xpos='875' ypos='1400' >
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3) 
 
 Set StatutDescritionERR = $Piece(context.StatutEnregInfo,"!##!",3)
 
 //description de l'erreur
 set context.resultUserDesc = $Replace(StatutDescritionERR,"!@@!","-")
 
  //Formatage du nom du fichier
 Set context.NomFichier= $Piece(context.NomFichier,"\",$Length(context.NomFichier,"\")) 
  
 
 //Construction du mail d'erreur
  Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"l'EAI a détécté une Warning pour une confirmation de la banque : "_context.BanqueTraitée_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Confirmation en erreurs : "_context.NomFichier_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Description de l'erreur :"_StatutDescritionERR_$c(13,10)_$c(13,10)


 

 Set context.MailErreurTexte = context.MailErreurTexte_$c(13,10)_$c(13,10)_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
 
 Set context.NomFichier= $Piece($Piece(context.NomFichier,"\",$Length(context.NomFichier,"\")) ,".",1)
]]>
</code>
<call name='Enregistrement Warning' target='Enregistrement Erreurs CFAO' async='0' xpos='875' ypos='1500' >
<request type='CFAO.HUBIC.Alertes.AlertMsg' >
<assign property="callrequest.MailErreurTexte" value="context.MailErreurTexte" action="set" />
<assign property="callrequest.Reason" value="context.Reason" action="set" />
<assign property="callrequest.ResultNomFichier" value="context.NomFichier" action="set" />
<assign property="callrequest.SourceConfigName" value="context.%Process.%ConfigName" action="set" />
<assign property="callrequest.ErrorType" value="&quot;1&quot;" action="set" />
<assign property="callrequest.ResultUserDesc" value="context.resultUserDesc" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert value='context.MailErreurTexte' xpos='875' ypos='1600' />
<transform name='Report WAR' class='CFAO.HUBIC.BofficeConf.Report.ConfBanqueTxt.DataTransform.ReportWAR' source='context.NomConfTXTenTraitement' target='context.contextReport' xpos='875' ypos='1700' />
</case>
<case condition='context.tSC.status = 0' name='Erreur fatale' >
<code xpos='1145' ypos='1300' disabled="true">
<![CDATA[ $$$LOGINFO("PASSAGE PAS OK")]]>
</code>
<code name='Construction Mail Erreur' xpos='1145' ypos='1400' >
<![CDATA[ //mise en forme de la date
 Set DateEnvoi = $piece($extract($ZDATETIME($NOW(),1),1,10),"/",2)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",1)_"/"_$piece($extract($ZDATETIME($NOW(),1),1,10),"/",3) 
 
 Set StatutDescritionERR = $Piece(context.StatutEnregInfo,"!##!",3)
 
 //description de l'erreur
 set context.resultUserDesc = $Replace(StatutDescritionERR,"!@@!","-")
 
  //Formatage du nom du fichier
 Set context.NomFichier= $Piece(context.NomFichier,"\",$Length(context.NomFichier,"\")) 
  
 
 //Construction du mail d'erreur
  Set context.MailErreurTexte = "Bonjour,"_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Nous sommes le "_DateEnvoi_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"l'EAI a détécté une Warning pour une confirmation de la banque : "_context.BanqueTraitée_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Confirmation en erreurs : "_context.NomFichier_$c(13,10)_$c(13,10)
 Set context.MailErreurTexte = context.MailErreurTexte_"Description de l'erreur :"_StatutDescritionERR_$c(13,10)_$c(13,10)
 

 

 Set context.MailErreurTexte = context.MailErreurTexte_$c(13,10)_$c(13,10)_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
 
 Set context.NomFichier= $Piece($Piece(context.NomFichier,"\",$Length(context.NomFichier,"\")) ,".",1)

]]>
</code>
<call name='Enregistrement erreur' target='Enregistrement Erreurs CFAO' async='0' xpos='1145' ypos='1500' >
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
<alert value='context.MailErreurTexte' xpos='1145' ypos='1600' />
<transform name='Report ERR' class='CFAO.HUBIC.BofficeConf.Report.ConfBanqueTxt.DataTransform.ReportERR' source='context.NomConfTXTenTraitement' target='context.contextReport' xpos='1145' ypos='1700' />
</case>
<default/>
</switch>
</sequence>
</process>
}

}
