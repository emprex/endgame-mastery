/*
 * Endgame Mastery
 * Stockfish WebWorker
 *
 * ------------------------------------------------------------
 * Responsibility
 * ------------------------------------------------------------
 *
 * This worker isolates Stockfish from Flutter's UI thread.
 *
 * Flutter sends plain UCI commands:
 *
 *   uci
 *   isready
 *   position fen ...
 *   go movetime 250
 *   stop
 *
 * Stockfish responses are forwarded unchanged to Flutter:
 *
 *   uciok
 *   readyok
 *   info ...
 *   bestmove ...
 *
 * ------------------------------------------------------------
 * Important
 * ------------------------------------------------------------
 *
 * Chess rules do NOT live here.
 *
 * Request IDs, stale-response rejection, game state and move
 * validation remain in Dart.
 */

importScripts('stockfish-18-lite-single.js');

/*
 * The Stockfish.js worker build communicates through the
 * worker's standard message channel.
 *
 * We deliberately keep this wrapper extremely small so the
 * higher-level Dart ChessEngine remains independent from the
 * Stockfish implementation.
 */
