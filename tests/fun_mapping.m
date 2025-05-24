% функция coreset pdcch mapping 
function [resource_grid,coreset_config] = fun_mapping(symbols)
arguments
    symbols % qpsk pdcch 
    % можно будет добавить данные из MIB
    % можно будет добавить данные из coreset config
    % можно будет добавить данные из SSB
end

    % 1. Для coreset 0 необходимы параметры из MIB

    coreset_config.rbs = 48;% 24 RB для CORESET0 у нас 48
    coreset_config.ssb_offset = 15; % Пример из TS 38.213 из MIB
    coreset_config.duration = 2; % 2 символа - число символов
    coreset_config.start_symbol = 7; % начало с 4-го символа
    coreset_config.num_cces = 4; % уровень агреации AL
    coreset_config.symbols = [coreset_config.start_symbol,coreset_config.start_symbol + coreset_config.duration];

    % 2. Произведём маппирование coreset 
    coreset0_pos = calculate_coreset0_pos(coreset_config.ssb_offset, coreset_config.rbs); % расчёт позиции coreset
                                                                                          % на ресурсной сетке
    coreset_config.freq_range = [coreset0_pos(1),coreset0_pos(length(coreset0_pos))];     % берём первый и последний символ

    % 3. Зададим параметры SSB - заменить на параметры ребят
    ssb_config.freq_range = [6, 25];       % SSB занимает RB 6-25 
    ssb_config.ssb_symbols = [3, 7];       % Символы 3-8

    % 4. Получим ресурсную сетку
    resource_grid = map_pdcch(symbols, coreset_config, ssb_config); % маппирование PDCCH на ресурсную сетку 
end



% Функция расчёта позиции coreset в частотной области
function coreset_rbs = calculate_coreset0_pos(ssb_offset, coreset_rbs_duration)
    % ssb_offset: смещение поднесущих SSB (из MIB, 0...23)
    % coreset_rbs: число RB в CORESET0 
    
    % SSB занимает 20 RB (240 поднесущих), но CORESET0 начинается после смещения
    ssb_end_rb = 25; % SSB последний rb пока что костыль 
    coreset_start_rb = floor((ssb_offset + ssb_end_rb)); % Смещение в RB 
   
    coreset_rbs = coreset_start_rb : coreset_start_rb + (coreset_rbs_duration)/2- 1;
end


% Функция маппирования на ресурсную сетку PDCCH
function resource_grid = map_pdcch(symbols, coreset_config, ssb_config)

    % Инициализация решётки 
   % resource_grid = complex(zeros(100*12, 14*2));

     % Get resource grid configuration
            caseLetter = 'C';
            absolutePointA = 4;
            config = caseConfiguration(caseLetter,absolutePointA);

            % Create resource grid
            channelBandwidth = 50;
            symbolsInHalfFrame = 2^config.mu * 14 * 5;
            symbolsAmount = symbolsInHalfFrame;
            resource_grid = ResourceGrid(symbolsAmount, channelBandwidth, config.mu);
    % 

    %{
        
    % Заполнение SSB 
    for rb = ssb_config.freq_range(1) : ssb_config.freq_range(2)
        for sym = ssb_config.ssb_symbols(1) : ssb_config.ssb_symbols(2)
            re_pos = (rb * 12 + 1) : ((rb + 1) * 12);
            resource_grid(re_pos, sym + 1) = 1 + 1i; % Маркер SSB
        end
    end
    %}
    % Заполнение PDCCH в CORESET
    reg_idx = 0;
    for rb = coreset_config.freq_range(1) : coreset_config.freq_range(2)
        for sym = coreset_config.start_symbol -1 : coreset_config.start_symbol + coreset_config.duration - 2
        %{
 Пропуск REG, если он в SSB
            if (rb >= ssb_config.freq_range(1)) && (rb <= ssb_config.freq_range(2)) && ...
               (sym >= ssb_config.symbols(1)) && (sym <= ssb_config.symbols(2))
                continue;
            end
         %}
            
            % Размещение 9 QPSK-символов на REG (исключая DM-RS)
            re_in_reg = 1;
            for k = 1:12
                if mod(k-1, 4) ~= 0 % Не DM-RS
                    re_pos = rb * 12 + k;
                    resource_grid.resourceGrid(re_pos, sym + 1) = symbols(reg_idx * 9 + re_in_reg);
                    re_in_reg = re_in_reg + 1;
                end
            end
            reg_idx = reg_idx + 1;
        end
    end
end