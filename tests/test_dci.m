
% test 
function resource_grid = test_dci(crc_type)
arguments 
    crc_type
end

% введём параметры для функции getDCI   unit test matlab, общий гит с 3-мя
% папками. что то у ребят с ofdm как то встроить
FDRA = 11; % 10,19967 округляется в большую сторону
TDRA = 1;
VrbPrb = 0;
modulation_and_coding_scheme = 0;
redundancy_Version = 0;
sII = 0b0;
reserved_bits = 0; % zeros(0,15)

% получим биты dci для формата format 1_0 в соответствие со стандартом
DM = getDCI(FDRA, TDRA, VrbPrb,modulation_and_coding_scheme,redundancy_Version,sII, reserved_bits);

% закодируем биты полезной нагрузки 38.212 с использование CRC attachment (раздел 7.3.2),
% Channel coding (7.3.3), Rate mathcing (раздел 7.3.4).
%crc_type = 'crc24c';

codeword = Encode_DCI(DM,crc_type);

% попытка сравнения с функция nrDCIEncode
bit_string = '10100001000000000000000000000000';
bit_vector = double(bit_string') - '0';  % Преобразуем в числовой вектор-столбец

% Get the PDCCH QPSK symbols nrPDCCH

nID = 2;  % задать у ребят 250
n_RNTI = 1; % задано стандартом 65535
symbols = get_pdcch_symbols(codeword, nID, n_RNTI);

symbols_2 = nrDCIEncode(bit_vector,n_RNTI, 2*length(DM)); % третий параметр не такой!
%isequal(codeword, symbols_2) - пока неудачно


%%% ВПИШЕМ СЮДА МАППИНГ

    [resource_grid,coreset_config] = fun_mapping(symbols);

    % Визуализация
   figure
   plt = pcolor(abs(resource_grid.resourceGrid));
   plt.EdgeColor = "none";
   xlabel ('OFDM symbols');
  ylabel  ("Subcarriers");
  end

%{

%               ПОЛУЧИМ ИСХОДНЫЕ БИТЫ DCI
% Необходимо воплотить функцию nrPDCCHDecode и получить из qpsk символов
% codeword
% Для этого: 1 - демодуляция; 2 - дескремблирование 


%%% ВЫТАЩИМ QPSK SYMBOLS PDCCH 

pdcch_symbols_rev = de_mapping(resource_grid, nID, n_RNTI,coreset_config).';
isequal(symbols,pdcch_symbols_rev) % совпали



% вытащим закодированные биты из qpsk
received_codeword = de_get_pdcch_symbols(pdcch_symbols_rev, nID, n_RNTI);

% проверка на совпадение codeword - удачно
%isequal(codeword, received_codeword)  

% Произведём декодирование последовательности DCI.
get_DM = Decode_DCI(received_codeword, crc_type);

isequal(get_DM, DM)


                 % Сделаем вид, что декодирование успешно
any_bits = DM; % якобы получили то же самое

dci_block = decom_dci(any_bits); % parser_dci
disp(dci_block)

if dci_block.VrbPrb == '0'
    disp('VrbPrb = 0. Non_interleaved');
else 
    disp('VrbPrb = 1. interleaved');
end

if dci_block.sII == '0'
    disp('sII = 0. SIB 1');
else
    disp('sII = 1. SI messages');
end

% Необходимо произвести слепое декодирование битов DCI 
% ещё не готово
%decode_dci = decode_payload(nID, n_RNTI);

% генерация dci и маппирование dci. как действительно лежит pdcch и coreset
% 0
%}




