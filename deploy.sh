# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "Flutter is not installed. Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:`pwd`/flutter/bin"
else
    echo "Flutter is already installed."
fi

# Proceed with the deployment
make deploy OUTPUT=whos_that_pokemon_client
