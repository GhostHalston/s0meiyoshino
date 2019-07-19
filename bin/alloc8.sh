#!/bin/bash
echo "Press enter key after put device in DFU mode."
read -p "<enter>: "
cd ipwndfu
./ipwndfu -p
./ipwndfu -x
cd ..

echo "Done!"
