import click
import pathlib
import sys
from .anonymizers import hashing, tokenization, k_anonymity, diff_privacy

@click.group()
def cli():
    """Log Anonymizer CLI – pilih metode anonimasi.
    """

@cli.command()
@click.argument('input_path', type=click.Path(exists=True))
@click.argument('output_path', type=click.Path())
@click.option('--algorithm', type=click.Choice(['hash','tokenize','k_anonymity','diff_privacy']), required=True)
@click.option('--columns', multiple=True, help='Kolom yang akan diproses (CSV).')
@click.option('--k', type=int, default=5, help='Parameter k untuk k-anonymity.')
@click.option('--epsilon', type=float, default=1.0, help='Parameter epsilon untuk differential privacy.')
def run(input_path, output_path, algorithm, columns, k, epsilon):
    """Baca INPUT_PATH, terapkan ALGORITHM, tulis ke OUTPUT_PATH.
    """
    p = pathlib.Path(input_path)
    out = pathlib.Path(output_path)
    if p.suffix.lower() in {'.csv', '.tsv'}:
        df = pd.read_csv(p)
        if algorithm == 'hash':
            df = hashing.hash_columns(df, columns)
        elif algorithm == 'tokenize':
            df = tokenization.tokenize_columns(df, columns)
        elif algorithm == 'k_anonymity':
            df = k_anonymity.apply_k_anonymity(df, list(columns), k)
        elif algorithm == 'diff_privacy':
            df = diff_privacy.add_laplace_noise(df, list(columns), epsilon)
        df.to_csv(out, index=False)
    else:
        # treat as plain text log
        text = p.read_text(encoding='utf-8')
        if algorithm == 'hash':
            out.write_text(hashing.hash_text(text))
        elif algorithm == 'tokenize':
            out.write_text(tokenization.tokenize_text(text))
        else:
            click.echo('Algorithm not supported for plain‑text logs.', err=True)
            sys.exit(1)
    click.echo(f'Anonymization complete → {out}')

if __name__ == '__main__':
    cli()
