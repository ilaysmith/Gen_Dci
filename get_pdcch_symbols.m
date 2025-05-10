% the function of receiving pdcch bits
function symbols = get_pdcch_symbols( ...
    codeword, ...
    nID, ...
    n_RNTI ...
    )
arguments
        codeword (1,:) % encoded payload
        nID (1,1)      % cell identificator (0...1007)
        n_RNTI (1,1)   % CRC mask required to decode the DCI message
end

% modeling a scrambling sequence
cinit = mod(double(n_RNTI)*2^16 + double(nID),2^31);

% getting the scrambling bits
scrambled = xor(codeword, cinit);

% modulation QPSK. qpskModulation - взято у Валентина
symbols = qpskModulation(scrambled);


end