Class CFAO.HUBIC.BofficeConf.BO.banks.masterClass Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// Available type
/// 0: TERM
/// 1: SPOT
/// 2: SWAP, PRORO, LEVEE
Method hasRequiredField(data As %Library.DynamicObject, type As %Integer) As %Boolean
{
	if data.bank			= ""
	|| data.tradeDate 		= ""
	|| data.amountReceived	= ""
	|| data.deviseReceived	= ""
	|| data.amountPaid		= ""
	|| data.devisePaid		= ""
	{
		return 0
	}

	if type = 0 {return (
		   data.maturityDate	'= ""
		&& data.term			'= ""
	)}

	if type = 1 {return (
		   data.valueDate		'= ""
		&& data.spot 			'= ""
	)}

	if type = 2 {return ( 
		   data.valueDate		'= ""
		&& data.maturityDate	'= ""
		&& data.spot			'= ""
		&& data.term			'= ""
	)}

	return 0
}

Method match(data As %Library.DynamicObject) As %Library.DynamicArray
{
	if data.valueDate 	 = "" {set valueDate 	= ""}	else {set valueDate 	= " AND valueDate = '" _ data.valueDate _ "'"}
	if data.maturityDate = "" {set maturityDate	= ""}	else {set maturityDate	= " AND maturityDate = '" _ data.maturityDate _ "'"}
	if data.term 		 = "" {set term			= ""}	else {set term			= " AND term = " _ data.term}
	if data.spot 		 = "" {set spot			= ""}	else {set spot			= " AND spot = " _ data.spot}

	set request =
		"SELECT"
			_" COUNT(*) AS ""match"""
			_",idForex"
			_",ID AS ""idEaiForex"""
		_" FROM CFAO_HUBIC_BofficeConf_tables.forex"
		_" WHERE"
			_" matchStatus = 0"
			_" AND tradeDate = '"_data.tradeDate_"'"
			_" AND bank = '"_data.bank_"'"
			_" AND deviseReceived = '"_data.deviseReceived_"'"
			_" AND devisePaid = '"_data.devisePaid_"'"
			_" AND amountReceived = '"_data.amountReceived_"'"
			_" AND amountPaid = '"_data.amountPaid_"'"
			_valueDate
			_maturityDate
			_term
			_spot

	return ##class(CFAO.HUBIC.Outils).queryJSON(request)
}

Method save(data As %Library.DynamicObject, match As %Integer) As %Library.DynamicObject
{
	set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.bank).save(data, match)

	set response = {}

	If 'tSC {
		set response.status = 0
    	set response.message =
			"Erreur lors de l'enregistrement de la confirmation : "_data.confFileName_$c(13, 10)
			_"tSC : "_tSC
		$$$LOGWARNING(tSC)
		return response
	}

	set idEaiBank = tSC

	if match {
		set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(data, match)

		if 'tSC {
			set response.status = 0
			set response.message =
				"Erreur lors de la mise à jour de la ligne forex : "_data.idEaiForex_$c(13, 10)
				_"tSC : "_tSC
			$$$LOGWARNING(tSC)
			return response
		}

		set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(idEaiBank)

		if 'tSC {
			set response.status = 0
			set response.message = tSC
			return response
		}
	}

	set response.status = 1

	return response
}

ClassMethod normalize(num) As %Status
{
	return $replace($p(num, ".", 1), ",", "")
}

}
