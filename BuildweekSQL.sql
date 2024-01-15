#Domanda 1: Trova il totale delle vendite per ogni mese.

SELECT month(datatransazione) AS MESE, sum(QuantitaAcquistata) AS QUANTITA
FROM transazioni
group by month(DataTransazione)
order by MESE;

#Domanda 2: Identifica i tre prodotti più venduti e la loro quantità venduta.

SELECT NomeProdotto,transazioni.ProdottoID,sum(quantitaacquistata) AS QUANTITAVENDUTA
FROM transazioni
JOIN  prodotti ON transazioni.ProdottoID = prodotti.ProdottoID
GROUP BY transazioni.ProdottoID
ORDER BY QUANTITAVENDUTA DESC
LIMIT 3;

#Domanda 3: Trova il cliente che ha effettuato il maggior numero di acquisti.

SELECT transazioni.ClienteID, NomeCliente, sum(QuantitaAcquistata) AS ACQUISTI 
FROM transazioni
JOIN clienti ON transazioni.ClienteID = clienti.ClienteID
GROUP BY QuantitaAcquistata, transazioni.ClienteID
ORDER BY ACQUISTI DESC
LIMIT 1;

#Domanda 4: Calcola il valore medio di ogni transazione.

SELECT MONTH(DataTransazione) AS MESE,p.categoria,
sum(QuantitaAcquistata*Prezzo)/count(t.ProdottoID) as ValoreMedio
from transazioni t
join prodotti p on p.ProdottoID = t.ProdottoID
group by Month(DataTransazione),p.Categoria
order by month(DataTransazione);


#Domanda 5: Determina la categoria di prodotto con il maggior numero di vendite.

SELECT Categoria,sum(QuantitaAcquistata) AS TOTVENDITA
FROM transazioni
JOIN prodotti ON transazioni.ProdottoID = prodotti.ProdottoID
GROUP BY Categoria
ORDER BY TOTVENDITA DESC
LIMIT 1;

#Domanda 6: Identifica il cliente con il maggior valore totale di acquisti.

SELECT ClienteID,sum(QuantitaAcquistata*Prezzo) AS SPESA
FROM transazioni
JOIN prodotti ON transazioni.ProdottoID = prodotti.ProdottoID
GROUP BY ClienteID
ORDER BY SPESA DESC
LIMIT 1;

#Domanda 7: Calcola la percentuale di spedizioni con "Consegna Riuscita".

SELECT (count(CASE WHEN StatusConsegna = 'Consegna Riuscita' THEN 1 END)/count(StatusConsegna))*100 AS PERCRIUSCITA
FROM spedizioni;

#OPPURE

SELECT (TOTRIUSCITA/TOT)*100 AS PERCRIUSCITA, TOTRIUSCITA,TOT
FROM (SELECT count(CASE WHEN StatusConsegna = 'Consegna Riuscita' THEN 1 END) AS TOTRIUSCITA, count(StatusConsegna) AS TOT
FROM spedizioni) conteggio;


#Domanda 8: Trova il prodotto con la recensione media più alta.

SELECT ProdottoID,avg(Rating) AS MEDIA,count(Rating) AS NUMRECENSIONI
FROM ratings
JOIN prodotti ON ratings.ProductID = prodotti.ProdottoID
GROUP BY ProdottoID
ORDER BY MEDIA desc, NUMRECENSIONI DESC
limit 1;

#Domanda 9: Calcola la variazione percentuale nelle vendite rispetto al mese precedente. 

SELECT 
	MESE,
	SommaVendite,
	LAG (SommaVendite) OVER (ORDER BY MESE) AS SommaMesePrima,
    (SommaVendite/LAG (SommaVendite) OVER (ORDER BY MESE)-1)*100 AS VARIAZIONEPERC
FROM (
	SELECT month(DataTransazione) AS MESE,sum(Prezzo) AS SommaVendite
	FROM prodotti
	JOIN transazioni ON prodotti.ProdottoID = transazioni.ProdottoID
	GROUP BY month(DataTransazione)
	order by MESE) TOTVENDITE
;

#Domanda 10: Determina la quantità media disponibile per categoria di prodotto.

select Categoria, avg(QuantitaDisponibile-QuantitaAcquistata) as QuantitaMediaDisponibile
from prodotti p
join transazioni t on t.ProdottoID=p.ProdottoID
group by Categoria ;

#Domanda 11: Trova il metodo di spedizione più utilizzato.

SELECT MetodoSpedizione, count(MetodoSpedizione) AS CONTEGGIO
FROM spedizioni
group by MetodoSpedizione;

#Domanda 12: Calcola il numero medio di clienti registrati al mese.

SELECT avg(CLIENTI) AS MEDIA,sum(CLIENTI) AS CLIENTI,count(MESE) AS MESE
FROM(
SELECT month(DataRegistrazione) AS MESE,year(DataRegistrazione) AS ANNO,count(ClienteID) AS CLIENTI
FROM clienti
GROUP BY month(DataRegistrazione), year(DataRegistrazione)) CONTEGGIO;

#ALTERNATIVE 
with Conteggio AS (
	SELECT month(DataRegistrazione) AS MESE,year(DataRegistrazione) AS ANNO,count(ClienteID) AS CLIENTI
	FROM clienti
	GROUP BY month(DataRegistrazione), year(DataRegistrazione)
)
SELECT avg(CLIENTI) AS MEDIA,sum(CLIENTI),count(MESE)
FROM Conteggio;


#Domanda 13: Identifica i prodotti con una quantità disponibile inferiore alla media.

SELECT NomeProdotto,QuantitaDisponibile
FROM prodotti 
WHERE QuantitaDisponibile < (
	SELECT avg(QuantitaDisponibile)
    FROM prodotti)
order by ProdottoID ;

#ALTERNATIVA CON DIFFERENZA DI QUANT ACQUISTATA E QUANT DISPONIBILE

WITH QuantitaDopoTransazioni AS (
    SELECT prodotti.NomeProdotto, 
           (prodotti.QuantitaDisponibile - COALESCE(SUM(transazioni.QuantitaAcquistata), 0)) AS QuantitaDopoTransazioni
    FROM prodotti 
    LEFT JOIN transazioni ON prodotti.ProdottoID = transazioni.ProdottoID
    GROUP BY prodotti.ProdottoID, prodotti.QuantitaDisponibile
)
SELECT NomeProdotto, QuantitaDopoTransazioni
FROM QuantitaDopoTransazioni
WHERE QuantitaDopoTransazioni < (SELECT AVG(QuantitaDopoTransazioni) FROM QuantitaDopoTransazioni)
ORDER BY QuantitaDopoTransazioni;

#Domanda 14: Per ogni cliente, elenca i prodotti acquistati e il totale speso

SELECT ClienteID,GROUP_CONCAT(transazioni.ProdottoID) AS LISTAPRODOTTI ,sum(QuantitaAcquistata*Prezzo) AS SPESA
FROM transazioni
JOIN prodotti ON transazioni.ProdottoID = prodotti.ProdottoID 
GROUP BY ClienteID;

#Domanda 15: Identifica il mese con il maggior importo totale delle vendite.

SELECT month(DataTransazione) AS MESE, sum(QuantitaAcquistata*Prezzo) AS IMPORTOTOT
FROM transazioni
JOIN prodotti ON transazioni.ProdottoID = prodotti.ProdottoID
GROUP BY month(DataTransazione)
ORDER BY IMPORTOTOT DESC
LIMIT 1;

#Domanda 16: Trova la quantità totale di prodotti disponibili in magazzino.

SELECT sum(QuantitaDisponibile) AS PRODOTTIDISP
FROM prodotti;

#ALTERNATIVA CON DIFFERENZA QUANT ACQUISTATA E QUANT DISPONIBILE
WITH QuantitaDopoOrdini AS (
    SELECT p.ProdottoID, 
           (p.QuantitaDisponibile - COALESCE(SUM(t.QuantitaAcquistata), 0)) AS QuantitaDisponibileDopoOrdini
    FROM prodotti p 
    LEFT JOIN transazioni t ON p.ProdottoID = t.ProdottoID
    GROUP BY p.ProdottoID, p.QuantitaDisponibile
)
SELECT SUM(QuantitaDisponibileDopoOrdini) AS Quantita_Tot_Disponibile_Dopo_Ordini
FROM QuantitaDopoOrdini
ORDER BY Quantita_Tot_Disponibile_Dopo_Ordini ;


#Domanda 17: Identifica i clienti che non hanno effettuato alcun acquisto.

SELECT clienti.ClienteID,NomeCliente
FROM transazioni
RIGHT JOIN clienti ON transazioni.ClienteID = clienti.ClienteID
WHERE transazioni.ClienteID is NULL;

#Domanda 18: Calcola il totale delle vendite per ogni anno.

SELECT year(DataTransazione) AS ANNO, sum(QuantitaAcquistata*Prezzo) AS IMPORTOTOT
FROM transazioni 
JOIN prodotti ON transazioni.ProdottoID = prodotti.ProdottoID
GROUP BY year(DataTransazione);

#Domanda 19:Trova la percentuale di spedizioni con "In Consegna" rispetto al totale.

SELECT count(CASE WHEN StatusConsegna = "In Consegna" THEN 1 END)/count(StatusConsegna)*100 AS PERCINCONSEGNA
FROM spedizioni;

#DOMANDE AGGIUNTIVE 

#Domanda 20: Trova i 5 prodotti più redditizi

SELECT p.Categoria, p.NomeProdotto, 
SUM(Prezzo) AS RicavoTotale
FROM prodotti p
GROUP BY p.Categoria, p.NomeProdotto
ORDER BY RicavoTotale DESC
LIMIT 5;

#Domanda 21 X ALTRI: Quali prodotti vendono meglio in determinati periodi dell’anno? Seleziona i primi 10

SELECT ProdottoID, DATE_FORMAT(DataTransazione, '%Y-%m') AS Mese, SUM(QuantitaAcquistata) as VenditeTotali
FROM Transazioni
GROUP BY ProdottoID, Mese
ORDER BY VenditeTotali DESC
LIMIT 10;

#Domanda 22: Categoria con recensioni più alte e categoria con recensioni più basse.
SELECT Categoria, AVG(Rating) AS MediaRecensioni
FROM Prodotti p
JOIN ratings r ON p.ProdottoID = r.ProductID
GROUP BY Categoria
ORDER BY MediaRecensioni DESC, Categoria;


#Domanda 23 X ALTRI: Seleziona i primi 3 clienti che hanno il prezzo medio di acquisto più alto in ogni categoria di prodotto.

SELECT c.ClienteID, p.Categoria, AVG(t.QuantitaAcquistata * p.Prezzo) AS PREZZOMEDIO
FROM transazioni t
JOIN clienti c ON t.ClienteID = c.ClienteID
JOIN prodotti p ON t.ProdottoID = p.ProdottoID
GROUP BY c.ClienteID, p.Categoria
ORDER BY PREZZOMEDIO DESC
LIMIT 3;

#Domanda 24: Calcolo della media della durata della spedizone.
select AVG(DATEDIFF(DataSpedizione, DataTransazione))
 AS MediaSpedizione
FROM transazioni;


#DOMANDE CONTEST:
#1. Quali prodotti vendono meglio in determinati periodi dell’anno?

SELECT ProdottoID, DATE_FORMAT(DataTransazione, '%Y-%m') AS Mese, SUM(QuantitaAcquistata) as VenditeTotali
FROM Transazioni
GROUP BY ProdottoID, Mese
ORDER BY VenditeTotali DESC
LIMIT 10;

#2. Selezione i primi 3 clienti che hanno il prezzo medio di acquisto più alto in ogni categoria di prodotto.

SELECT c.ClienteID, p.Categoria, AVG(t.QuantitaAcquistata * p.Prezzo) AS PREZZOMEDIO
FROM transazioni t
JOIN clienti c ON t.ClienteID = c.ClienteID
JOIN prodotti p ON t.ProdottoID = p.ProdottoID
GROUP BY c.ClienteID, p.Categoria
ORDER BY PREZZOMEDIO DESC
LIMIT 3;

#3. Numero di prodotti con una quantità disponibile inferiore alla media.

WITH QuantitaDopoTransazioni AS (
    SELECT prodotti.NomeProdotto, 
           (prodotti.QuantitaDisponibile - COALESCE(SUM(transazioni.QuantitaAcquistata), 0)) AS QuantitaDopoTransazioni
    FROM prodotti 
    LEFT JOIN transazioni ON prodotti.ProdottoID = transazioni.ProdottoID
    GROUP BY prodotti.ProdottoID, prodotti.QuantitaDisponibile
)
SELECT NomeProdotto, QuantitaDopoTransazioni
FROM QuantitaDopoTransazioni
WHERE QuantitaDopoTransazioni < (SELECT AVG(QuantitaDopoTransazioni) FROM QuantitaDopoTransazioni)
ORDER BY QuantitaDopoTransazioni;

#4.Media delle recensioni dei clienti il cui tempo di elaborazione dell'ordine è inferiore a 30gg 

SELECT RatingID, avg(DataSpedizione-DataTransazione) AS TEMPOELABORAZIONE
FROM ratings
JOIN transazioni ON ratings.ProductID = transazioni.ProdottoID
GROUP BY ProductID,RatingID
HAVING TEMPOELABORAZIONE <30;

#5.Valutazione del tempo in anni in cui viene gestita una spedizione con visualizzazione di "Più di un anno" o "Meno di un anno" 
#in una colonna calcolata.

SELECT s.SpedizioneID,s.DataSpedizione,
CASE WHEN datediff(t.DataSpedizione,t.DataTransazione) > 365 THEN 'Più di un anno'
WHEN datediff(t.DataSpedizione,t.DataTransazione) < 365 THEN 'Meno di un anno'
ELSE 'Un anno esatto' END AS ValutazioneTempo
FROM spedizioni s
JOIN transazioni t ON s.SpedizioneID = t.SpedizioneID;

#6.Totale delle disponibilità in magazzino dei prodotti divisi per categoria

SELECT Categoria, SUM(QuantitaDisponibile) AS TotaleDisponibilita
FROM prodotti
GROUP BY Categoria;

#7.Si vuole stampare Nome del cliente, Importo transazione (prezzo * quantità),Nome Prodotto e Rating MEDIO del prodotto.
#Aggiungere colonna OUTPUT che avrà i seguenti valori:SE la transazione supera il valore medio di tutte le transazioni
#dell’anno stampare “Sopra La Media” altrimenti “Sotto la media”






























