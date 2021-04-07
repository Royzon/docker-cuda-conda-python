import yaml
import re


def process_file(filepath,
                 python_version,
                 cuda_version):
    with open(filepath, 'r') as f:
        content = yaml.safe_load(f)

    versions = {'python': python_version, 'cudatoolkit': cuda_version}

    for lib, version in versions.items():

        replace = f"{lib}={version}"
        pattern = rf"{lib}[>=]*[\d\.]*"

        for idx, req in enumerate(content['dependencies']):
            content['dependencies'][idx] = re.sub(pattern, replace, req)

    with open(filepath, 'w') as f:
        yaml.dump(content, f)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--conda_file')
    parser.add_argument('--python_version')
    parser.add_argument('--cuda_version')

    args = parser.parse_args()
    process_file(filepath=args.conda_file,
                 python_version=args.python_version,
                 cuda_version=args.cuda_version)
