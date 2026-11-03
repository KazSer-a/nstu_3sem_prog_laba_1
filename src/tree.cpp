#include "tree.h"

#include <iostream>
#include <queue>
#include <stdexcept>
#include <vector>

TreeNode* insert(TreeNode* root, int key)
{
    TreeNode* node = new TreeNode{key, nullptr, nullptr};
    if (root == nullptr) return node;

    TreeNode* current = root;
    while (true)
    {
        if (key < current->key)
        {
            if (current->left == nullptr)
            {
                current->left = node;
                break;
            }
            current = current->left;
        }
        else
        {
            if (current->right == nullptr)
            {
                current->right = node;
                break;
            }
            current = current->right;
        }
    }
    return root;
}

TreeNode* search(TreeNode* root, int key)
{
    TreeNode* current = root;
    while (current != nullptr)
    {
        if (current->key == key) return current;
        current = key < current->key ? current->left : current->right;
    }
    return nullptr;
}

bool isFull(TreeNode* root)
{
    if (root == nullptr) return true;
    if ((root->left == nullptr) != (root->right == nullptr)) return false;
    return isFull(root->left) && isFull(root->right);
}

void preorder(TreeNode* root)
{
    if (root == nullptr) return;
    std::cout << root->key << " ";
    preorder(root->left);
    preorder(root->right);
}

void inorder(TreeNode* root)
{
    if (root == nullptr) return;
    inorder(root->left);
    std::cout << root->key << " ";
    inorder(root->right);
}

void postorder(TreeNode* root)
{
    if (root == nullptr) return;
    postorder(root->left);
    postorder(root->right);
    std::cout << root->key << " ";
}

void bfs(TreeNode* root)
{
    if (root == nullptr) return;
    std::queue<TreeNode*> nodes;
    nodes.push(root);
    while (!nodes.empty())
    {
        TreeNode* current = nodes.front();
        nodes.pop();
        std::cout << current->key << " ";
        if (current->left != nullptr) nodes.push(current->left);
        if (current->right != nullptr) nodes.push(current->right);
    }
}

void freeTree(TreeNode* root)
{
    if (root == nullptr) return;
    freeTree(root->left);
    freeTree(root->right);
    delete root;
}

void handleTree(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "tree")) return;
    TreeNode* root = nullptr;

    try
    {
        for (const std::string& item : getItems(db, name))
        {
            size_t pos = 0;
            int value = std::stoi(item, &pos);
            if (pos != item.size()) throw std::invalid_argument("value");
            root = insert(root, value);
        }
    }
    catch (...)
    {
        std::cout << "неверные данные дерева\n";
        freeTree(root);
        return;
    }

    int value;
    switch (command)
    {
        case Command::TINSERT:
            if (!(ss >> value)) std::cout << "не хватает аргументов или неверное число\n";
            else { root = insert(root, value); std::cout << "-> " << value << "\n"; }
            break;
        case Command::TFIND:
            if (!(ss >> value)) std::cout << "не хватает аргументов или неверное число\n";
            else std::cout << (search(root, value) != nullptr ? "-> TRUE\n" : "-> FALSE\n");
            break;
        case Command::TFULL:
            std::cout << (isFull(root) ? "-> TRUE\n" : "-> FALSE\n");
            break;
        case Command::TPRINT:
            std::cout << "прямой:       "; preorder(root); std::cout << "\n";
            std::cout << "симметричный: "; inorder(root); std::cout << "\n";
            std::cout << "обратный:     "; postorder(root); std::cout << "\n";
            std::cout << "в ширину:     "; bfs(root); std::cout << "\n";
            break;
        default:
            break;
    }

    std::vector<std::string> data;
    if (root != nullptr)
    {
        std::queue<TreeNode*> nodes;
        nodes.push(root);
        while (!nodes.empty())
        {
            TreeNode* current = nodes.front();
            nodes.pop();
            data.push_back(std::to_string(current->key));
            if (current->left != nullptr) nodes.push(current->left);
            if (current->right != nullptr) nodes.push(current->right);
        }
    }
    saveItems(db, name, "tree", data);
    freeTree(root);
}
