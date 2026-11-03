#pragma once

#include "commands.h"

struct TreeNode
{
    int key;
    TreeNode* left;
    TreeNode* right;
};

TreeNode* insert(TreeNode* root, int key);
TreeNode* search(TreeNode* root, int key);
bool isFull(TreeNode* root);
void preorder(TreeNode* root);
void inorder(TreeNode* root);
void postorder(TreeNode* root);
void bfs(TreeNode* root);
void freeTree(TreeNode* root);
void handleTree(Command command, Database& db, const std::string& name, std::stringstream& ss);
