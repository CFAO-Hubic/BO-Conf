Class CFAO.HUBIC.BofficeConf.BO.banks.masterClass Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method save(data As %Library.DynamicObject, match As %Integer) As %Library.DynamicObject
{
	set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.bank).save(data, match)

	set response = {}

	If 'tSC {
		set response.status = 0
    	set response.message = "Erreur lors de l'enregistrement de la confirmation : "_data.bankFileName
		return response
	}

	set idEaiBank = tSC

	if match {
		set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(data, match)

		if 'tSC {
			set response.status = 0
			set response.message = "Erreur lors de la mise à jour de la ligne forex : "_data.idEaiForex
			return response
		}

		set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(data.idEaiBank)

		if 'tSC {
			set response.status = 0
			set response.message = tSC
			return response
		}
	}

	set response.status = 1

	return response
}

Method match(data As %Library.DynamicObject) As %Library.DynamicObject
{
	if data.valueDate 	 = "" {set valueDate 	= ""}	else {set valueDate 	= " AND valueDate = " _ data.valueDate}
	if data.maturityDate = "" {set maturityDate	= ""}	else {set maturityDate	= " AND maturityDate = " _ data.maturityDate}
	if data.term 		 = "" {set term			= ""}	else {set term			= " AND term = " _ data.term}
	if data.spot 		 = "" {set spot			= ""}	else {set spot			= " AND spot = " _ data.spot}

	set request =
		"SELECT "
			_"COUNT(*) AS ""match"","
			_"idForex,"
			_"ID AS ""idEaiForex"" "
		_"FROM CFAO_HUBIC_BofficeConf_tables.forex "
		_"WHERE "
			_"matchStatus = 0"
			_" AND tradeDate = '"_data.tradeDate_"'"
			_" AND bank = '"_data.bank_"'"
			_" AND deviseBuy = '"_data.deviseBuy_"'"
			_" AND deviseSell = '"_data.deviseSell_"'"
			_" AND amountBuy = '"_data.amountBuy_"'"
			_" AND amountSell = '"_data.amountSell_"'"
			_valueDate
			_maturityDate
			_term
			_spot

	return ##class(CFAO.PARAM.PORTAL.utils).query(request)
}

/// Available type
/// 0: MEP
/// 1: SPOT
/// 2: SWAP, PRORO, LEVEE
Method hasRequiredField(data As %Library.DynamicObject, type As %Integer) As %Boolean
{
	if data.tradeDate	= ""
	|| data.amountBuy	= ""
	|| data.deviseBuy	= ""
	|| data.amountSell	= ""
	|| data.deviseSell	= ""
	|| data.bank 		= ""
	{
		return 0
	}

	if type = 0 {
		if 'data.maturityDate	= ""
		|| 'data.term			= ""
		{
			return 0
		} else {
			return 1
		}
	}

	if type = 1 {
		if 'data.valueDate	= ""
		|| 'data.spot 		= ""
		{
			return 0
		} else {
			return 1
		}
	}

	if type = 2 {
		if 'data.valueDate		= ""
		|| 'data.maturityDate	= ""
		|| 'data.spot			= ""
		|| 'data.term			= ""
		{
			return 0
		} else {
			return 1
		}
	}
}

}
