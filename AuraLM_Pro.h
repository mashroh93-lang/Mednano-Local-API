#ifndef AURALM_PRO_H
#define AURALM_PRO_H
#include <torch/torch.h>
#include <iostream>
#include <unordered_map>
#include <fstream>
#include <sstream>

class Tokenizer {
public:
    std::unordered_map<std::string, int> word_to_id;
    int current_id = 1;
    void train(std::string text) {
        if (word_to_id.empty()) { word_to_id["<unknown>"] = 0; }
        std::stringstream ss(text); std::string word;
        while (ss >> word) {
            if (word_to_id.find(word) == word_to_id.end()) {
                word_to_id[word] = current_id++;
            }
        }
    }
};
#endif
