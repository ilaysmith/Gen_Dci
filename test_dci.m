
% test 

% введём параметры для функции getDCI
FDMA = 10;
TDMA = 1;
VrbPrb = 0;
modulation_and_coding_scheme = 0;
redundancy_Version = 0;
sII = 0b0;
reserved_bits = 0; % zeros(0,15)

% получим биты dci для формата format 1_0 в соответствие со стандартом
DM = getDCI(FDMA, TDMA, VrbPrb,modulation_and_coding_scheme,redundancy_Version,sII, reserved_bits);


% закодируем биты полезной нагрузки 38.212 с использование CRC attachment (раздел 7.3.2),
% Channel coding (7.3.3), Rate mathcing (раздел 7.3.4).
crc_type = 'crc24c';

codeword = Encode_DCI(DM,crc_type);

% Get the PDCCH QPSK symbols nrPDCCH

nID = ;
n_RNTI = ;
symbols = get_pdcch_symbols(codeword, nID, n_RNTI);

% Необходимо произвести слепое декодирование битов DCI 

decode_dci = decode_payload(nID, n_RNTI);

