Class CFAO.HUBIC.BofficeConf.functions.commons Extends Ens.Rule.FunctionSet
{

ClassMethod sendConfEmail(idEaiBank As %String) As %Status
{
    Set DestinataireNom = ""
	Set DestinataireMail = ""
	Set DestinataireCopy = ""
	Set NomBanque = ""
	set RepertoirePJ = ^boConfSettings.pathPDF
	Set ExpediteurMail = ^boConfSettings.sender
	set SMTP = ^boConfSettings.SMTP

	Set lineBank = ##class(CFAO.HUBIC.BofficeConf.tables.bank).%OpenId(idEaiBank)
	if lineBank.idEaiForex = "" return "Line hasn't been matched yet"

	Set lineForex = ##class(CFAO.HUBIC.BofficeConf.tables.forex).%OpenId(lineBank.idEaiForex)

	&SQL(
		SELECT
			DestinataireNom,
			DestinataireMail,
			DestinataireMailCopy,
			NomBanque
		INTO
			:DestinataireNom,
			:DestinataireMail,
			:DestinataireMailCopy,
			:NomBanque
		FROM CFAO_HUBIC_BofficeConf_Table.ListeBanqueEtMail
		WHERE CodeBanque = :lineBank.bank
	)

	If $Replace(DestinataireMail," ","") = "" {
		do ..updateEmailStatus(idEaiBank, 2)
		return "Pas de destinataire"
	}

	Set ObjetMail = "CFAO/"_ NomBanque _" - Transaction confirmation "_lineBank.contrat
	Set nomPJ = $Replace(lineBank.confFileName _ ".pdf"," ","_")

	// Contenue du mail
	Set ContenuDuMail = ##class(%Stream.GlobalCharacter).%New()
	Do ContenuDuMail.Write(
		 "Bonjour,"_$c(13,10)
		_$c(13,10)
		_"Nous confirmons l'opération dont la référence est " _ lineBank.contrat _ ".Vous trouverez en pièce jointe la confirmation."_$c(13,10)
		_$c(13,10)
		_"Ceci est un mail automatique, merci de ne pas répondre. En cas de problème, adresser votre demande à confirmationforex@cfao.com."_$c(13,10)
		_$c(13,10)
		_"--"_$c(13,10)
		_$c(13,10)
		_"Good aftertoon,"_$c(13,10)
		_$c(13,10)
		_"We hereby confirm the deal under ref " _ lineBank.contrat _ ". Please find attached the confirmation."_$c(13,10)_$c(13,10)
		_"This is an automatique email, please do not reply. If you have any issues, please contact us at confirmationforex@cfao.com."_$c(13,10)
		_$c(13,10)
		_"Service Back Office Forex"_$c(13,10)
		_"Direction des Financements et de la Trésorerie"_$c(13,10)
		_"Tél. : +33 (0) 1 46 23 56 08"_$c(13,10)
		_"Fax : +33 (0) 1 46 23 56 97"_$c(13,10)
		_"18, rue Troyon - 92 316 Sèvres Cedex - France"_$c(13,10)
		_"confirmationforex@cfao.com  / www.cfaogroup.com"_$c(13,10)
	)

	Set tSC = ##class(CFAO.HUBIC.Outils).SendEmailGeneric(SMTP,DestinataireMail,DestinataireMailCopy,ExpediteurMail,ObjetMail,ContenuDuMail,RepertoirePJ,nomPJ)

	set repertoireSourcePJPDF = RepertoirePJ_nomPJ
	set repertoireArchivePDF = "\\10.0.60.51\root\Comptabilite\EMIR\ArchiveConfirmationBanquePDF\"_nomPJ
	Set sc=$zf(-1, "copy """_repertoireSourcePJPDF_ """ """_repertoireArchivePDF_"""")

	If ('tSC) {
		do ..updateEmailStatus(idEaiBank, 1)
		return "Erreur lors de l'envoi, Pas de destinataire"
	}else{
		do ..updateEmailStatus(idEaiBank, 0)
		return 1
	}
}

ClassMethod updateEmailStatus(idEaiBank As %String, emailStatus As %String = 0)
{
	if emailStatus = 0 Set emailDate = $ZDATETIME($h, 4)
	if emailStatus '= 0 Set emailDate = ""

	Set lineBank =  ##class(CFAO.HUBIC.BofficeConf.tables.bank).%OpenId(idEaiBank)

	&SQL(
		UPDATE CFAO_HUBIC_BofficeConf_tables.bank
		SET
			emailStatus = :emailStatus,
			emailDate = :emailDate
		WHERE idEaiForex = :lineBank.idEaiForex
	)

	&SQL(
		UPDATE CFAO_HUBIC_BofficeConf_tables.forex
		SET
			emailStatus = :emailStatus,
			emailDate = :emailDate
		WHERE ID = :lineBank.idEaiForex
	)
}

}
