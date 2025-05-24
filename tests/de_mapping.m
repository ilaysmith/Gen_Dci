function pdcch_symbols = de_mapping(resource_grid, nID, nRNTI,coreset_config)
    % 1. Извлечение RE PDCCH из CORESET
    % слепым декодированием будет, если пройти эту фукнцию для AL = 4, 8,
    % 16

   

    ssb_config.freq_range = [6, 25];       % SSB занимает RB 6-25 
    ssb_config.ssb_symbols = [3, 7];       % Символы 3-8

    pdcch_symbols = extract_pdcch_from_coreset(resource_grid, coreset_config,ssb_config);

    
  
    % 2. QPSK-демодуляция
    %llr = nrSymbolDemodulate(pdcch_symbols, 'QPSK'); % use qpsk_demodulate
    
    % 3. Дескремблирование
    %c = nrPDCCHPRBS(nID, nRNTI, length(llr)); % use descrambling
   % descrambled = mod(llr + c, 2);
    
    % 4. Rate Recovery

    % 5. Polar decoding 

    % 6. De_attach_parity_bits

    % 7. Извлечение DCI

    
    % 4. Слепое декодирование (проверка CRC)
  
end

function pdcch_symbols = extract_pdcch_from_coreset(resource_grid, coreset_config, ssb_config)
    % resource_grid: полная ресурсная решётка (поднесущие × символы)
    % coreset_config: параметры CORESET0
    % ssb_config: параметры SSB
    
    pdcch_symbols = [];
    reg_count = 0;
    
    % Non-interleaved маппинг (для CORESET0)
    for rb = coreset_config.freq_range(1) : coreset_config.freq_range(2)
        for sym = coreset_config.start_symbol : coreset_config.start_symbol + coreset_config.duration - 1
            % Пропуск REG, если он в SSB
            if (rb >= ssb_config.freq_range(1)) && (rb <= ssb_config.freq_range(2)) && ...
               (sym >= ssb_config.symbols(1)) && (sym <= ssb_config.symbols(2))
                continue;
            end
            
            % Извлечение 9 полезных RE из REG (исключая DM-RS)
            re_in_reg = [];
            for sc = 1:12
                if mod(sc-1, 4) ~= 0 % Не DM-RS
                    re_pos = rb * 12 + sc;
                    re_in_reg = [re_in_reg; resource_grid(re_pos, sym + 1)];
                end
            end
            pdcch_symbols = [pdcch_symbols; re_in_reg];
            reg_count = reg_count + 1;
        end
    end
end